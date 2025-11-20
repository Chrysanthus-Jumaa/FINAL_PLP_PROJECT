from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .models import User
from .serializers import UserRegistrationSerializer, UserSerializer
from rest_framework import serializers

# Register View
@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """
    Register a new user (restorer or organization)
    """
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        
        return Response({
            'message': 'Registration successful',
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Login View
@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """
    Login user and return JWT tokens
    """
    email = request.data.get('email')
    password = request.data.get('password')
    
    if not email or not password:
        return Response({
            'error': 'Email and password are required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Find user by email
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({
            'error': 'Invalid email or password'
        }, status=status.HTTP_401_UNAUTHORIZED)
    
    # Check password
    if not user.check_password(password):
        return Response({
            'error': 'Invalid email or password'
        }, status=status.HTTP_401_UNAUTHORIZED)
    
    # Generate JWT tokens
    refresh = RefreshToken.for_user(user)
    
    return Response({
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'user': UserSerializer(user).data
    }, status=status.HTTP_200_OK)


# Get Current User Profile
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_profile(request):
    """
    Get current authenticated user's profile
    """
    serializer = UserSerializer(request.user)
    return Response(serializer.data, status=status.HTTP_200_OK)


from django.db.models import Q
from .models import (
    County, Subcounty, RestorationType, LandListing, 
    LandRestorationType, MatchRequest, Notification
)
from .serializers import (
    CountySerializer, SubcountySerializer, RestorationTypeSerializer,
    LandListingSerializer, MatchRequestSerializer, NotificationSerializer,
    UserProfileUpdateSerializer
)


# Get Counties
@api_view(['GET'])
@permission_classes([AllowAny])
def get_counties(request):
    """
    Get all counties
    """
    counties = County.objects.all()
    serializer = CountySerializer(counties, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# Get Subcounties by County
@api_view(['GET'])
@permission_classes([AllowAny])
def get_subcounties(request, county_id):
    """
    Get subcounties for a specific county
    """
    subcounties = Subcounty.objects.filter(county_id=county_id)
    serializer = SubcountySerializer(subcounties, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# Get Restoration Types
@api_view(['GET'])
@permission_classes([AllowAny])
def get_restoration_types(request):
    """
    Get all restoration types
    """
    types = RestorationType.objects.all()
    serializer = RestorationTypeSerializer(types, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# Update User Profile
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_user_profile(request):
    """
    Update current user's profile
    """
    serializer = UserProfileUpdateSerializer(
        request.user, 
        data=request.data, 
        partial=True
    )
    
    if serializer.is_valid():
        serializer.save()
        return Response({
            'message': 'Profile updated successfully',
            'user': UserSerializer(request.user).data
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Land Listings Views
class LandListingListCreateView(generics.ListCreateAPIView):
    """
    List land listings or create new one
    - Organizations see all available listings (not deleted)
    - Restorers see only their own listings (including deleted)
    """
    serializer_class = LandListingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        
        if user.role == 'organization':
            # Organizations see all available (not soft-deleted) listings
            queryset = LandListing.objects.filter(
                is_deleted=False,
                availability='available'
            )
            
            # Apply filters
            county_id = self.request.query_params.get('county')
            restoration_type = self.request.query_params.get('restoration_type')
            min_size = self.request.query_params.get('min_size')
            max_size = self.request.query_params.get('max_size')
            
            if county_id:
                queryset = queryset.filter(county_id=county_id)
            
            if restoration_type:
                queryset = queryset.filter(
                    restoration_types__restoration_type__name=restoration_type
                ).distinct()
            
            if min_size:
                queryset = queryset.filter(size_acres__gte=min_size)
            
            if max_size:
                queryset = queryset.filter(size_acres__lte=max_size)
            
            # Randomize if no filters
            if not any([county_id, restoration_type, min_size, max_size]):
                queryset = queryset.order_by('?')[:20]
            
            return queryset
        
        else:  # restorer
            # Restorers see only their own listings (including deleted)
            return LandListing.objects.filter(user=user).exclude(is_deleted=True)
    
    def perform_create(self, serializer):
        # Only restorers can create land listings
        if self.request.user.role != 'restorer':
            raise serializers.ValidationError("Only restorers can create land listings")
        
        serializer.save(user=self.request.user)


class LandListingDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update or delete a land listing
    """
    serializer_class = LandListingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return LandListing.objects.filter(user=self.request.user)
    
    def perform_destroy(self, instance):
        from rest_framework.exceptions import ValidationError
    
        # Check if can delete (no pending/accepted requests)
        pending_or_accepted = MatchRequest.objects.filter(
            land_listing=instance,
            status__in=['pending', 'accepted']
        ).exists()
        
        if pending_or_accepted:
            raise ValidationError(
                "Cannot delete. This land has pending or accepted match requests. "
                "Please resolve them first."
            )
        
        # Soft delete
        instance.soft_delete()


# Match Request Views
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_match_request(request):
    """
    Organization creates a match request for a land listing
    """
    if request.user.role != 'organization':
        return Response({
            'error': 'Only organizations can create match requests'
        }, status=status.HTTP_403_FORBIDDEN)
    
    land_listing_id = request.data.get('land_listing_id')
    
    try:
        land_listing = LandListing.objects.get(id=land_listing_id, is_deleted=False)
    except LandListing.DoesNotExist:
        return Response({
            'error': 'Land listing not found'
        }, status=status.HTTP_404_NOT_FOUND)
    
    # Check if already requested
    existing_request = MatchRequest.objects.filter(
        organization=request.user,
        land_listing=land_listing
    ).first()
    
    if existing_request:
        return Response({
            'error': 'You have already requested this land listing'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Create match request
    match_request = MatchRequest.objects.create(
        organization=request.user,
        restorer=land_listing.user,
        land_listing=land_listing,
        status='pending'
    )
    
    # Create notification for restorer
    Notification.objects.create(
        user=land_listing.user,
        type='new_request',
        message='A new request has been made',
        match_request=match_request
    )
    
    return Response({
        'message': 'Match request created successfully',
        'match_request': MatchRequestSerializer(match_request).data
    }, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_match_requests(request):
    """
    Get match requests for current user
    - Restorers see requests they received
    - Organizations see requests they sent
    """
    if request.user.role == 'restorer':
        match_requests = MatchRequest.objects.filter(restorer=request.user)
    else:  # organization
        match_requests = MatchRequest.objects.filter(organization=request.user)
    
    serializer = MatchRequestSerializer(match_requests, many=True, context={'request': request})
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_match_request_detail(request, request_id):
    """
    Get details of a specific match request
    """
    try:
        if request.user.role == 'restorer':
            match_request = MatchRequest.objects.get(id=request_id, restorer=request.user)
        else:
            match_request = MatchRequest.objects.get(id=request_id, organization=request.user)
        
        serializer = MatchRequestSerializer(match_request, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    except MatchRequest.DoesNotExist:
        return Response({
            'error': 'Match request not found'
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_match_request_status(request, request_id):
    """
    Restorer accepts or declines a match request
    """
    if request.user.role != 'restorer':
        return Response({
            'error': 'Only restorers can update match request status'
        }, status=status.HTTP_403_FORBIDDEN)
    
    try:
        match_request = MatchRequest.objects.get(id=request_id, restorer=request.user)
    except MatchRequest.DoesNotExist:
        return Response({
            'error': 'Match request not found'
        }, status=status.HTTP_404_NOT_FOUND)
    
    action = request.data.get('action')  # 'accept' or 'decline'
    
    if action not in ['accept', 'decline']:
        return Response({
            'error': 'Invalid action. Use "accept" or "decline"'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    if match_request.status != 'pending':
        return Response({
            'error': 'This request has already been processed'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    if action == 'accept':
        # Check if land already has accepted match
        existing_accepted = MatchRequest.objects.filter(
            land_listing=match_request.land_listing,
            status='accepted'
        ).exists()
        
        if existing_accepted:
            return Response({
                'error': 'This land already has an accepted collaboration'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Accept this request
        match_request.status = 'accepted'
        match_request.save()
        
        # Mark land as unavailable
        land_listing = match_request.land_listing
        land_listing.availability = 'unavailable'
        land_listing.save()
        
        # Update other pending requests to 'land_no_longer_available'
        other_pending = MatchRequest.objects.filter(
            land_listing=land_listing,
            status='pending'
        ).exclude(id=match_request.id)
        
        for other_request in other_pending:
            other_request.status = 'land_no_longer_available'
            other_request.save()
            
            # Notify those organizations
            Notification.objects.create(
                user=other_request.organization,
                type='request_declined',  # Using declined type for consistency
                message='A land listing you requested is no longer available',
                match_request=other_request
            )
        
        # Notify the accepted organization
        Notification.objects.create(
            user=match_request.organization,
            type='request_accepted',
            message='Your request has been accepted',
            match_request=match_request
        )
        
        # TODO: Send email to both parties (we'll implement this later)
        
        return Response({
            'message': 'Match request accepted successfully',
            'match_request': MatchRequestSerializer(match_request, context={'request': request}).data
        }, status=status.HTTP_200_OK)
    
    else:  # decline
        match_request.status = 'declined'
        match_request.save()
        
        # Notify organization
        Notification.objects.create(
            user=match_request.organization,
            type='request_declined',
            message='Your request has been declined',
            match_request=match_request
        )
        
        return Response({
            'message': 'Match request declined',
            'match_request': MatchRequestSerializer(match_request, context={'request': request}).data
        }, status=status.HTTP_200_OK)


# Notification Views
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_notifications(request):
    """
    Get notifications for current user
    """
    notifications = Notification.objects.filter(user=request.user, is_read=False)
    serializer = NotificationSerializer(notifications, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_notification_read(request, notification_id):
    """
    Mark a notification as read
    """
    try:
        notification = Notification.objects.get(id=notification_id, user=request.user)
        notification.is_read = True
        notification.save()
        
        return Response({
            'message': 'Notification marked as read'
        }, status=status.HTTP_200_OK)
    
    except Notification.DoesNotExist:
        return Response({
            'error': 'Notification not found'
        }, status=status.HTTP_404_NOT_FOUND)
    
# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt

# @csrf_exempt
# def seed_database(request):
#     """ONE-TIME USE ONLY - Remove after seeding"""
#     if request.method == 'POST':
#         secret = request.POST.get('secret')
#         if secret != 'seed-my-database-now':
#             return JsonResponse({'error': 'Unauthorized'}, status=403)
        
#         from django.core.management import call_command
#         try:
#             call_command('seed_data')
#             return JsonResponse({'message': 'Database seeded successfully'})
#         except Exception as e:
#             return JsonResponse({'error': str(e)}, status=500)
#     return JsonResponse({'error': 'POST required'}, status=400)