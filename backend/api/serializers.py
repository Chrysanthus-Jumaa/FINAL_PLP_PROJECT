from rest_framework import serializers
from django.utils import timezone
from .models import (
    User, County, Subcounty, RestorationType,
    UserRestorationType, LandListing, LandRestorationType,
    MatchRequest, Notification
)


# County Serializer
class CountySerializer(serializers.ModelSerializer):
    class Meta:
        model = County
        fields = ['id', 'name']


# Subcounty Serializer
class SubcountySerializer(serializers.ModelSerializer):
    county_name = serializers.CharField(source='county.name', read_only=True)
    
    class Meta:
        model = Subcounty
        fields = ['id', 'name', 'county', 'county_name']


# Restoration Type Serializer
class RestorationTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = RestorationType
        fields = ['id', 'name', 'display_name']


# User Registration Serializer
class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    confirm_password = serializers.CharField(write_only=True)
    restoration_type_ids = serializers.ListField(
        child=serializers.IntegerField(),
        write_only=True,
        required=False
    )
    
    class Meta:
        model = User
        fields = [
            'email', 'password', 'confirm_password', 'role',
            'first_name', 'last_name', 'phone', 'county', 'subcounty',
            'organization_name', 'restoration_type_ids', 'terms_accepted'
        ]
    
    def validate(self, data):
        # Password match validation
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError({"password": "Passwords must match"})
        
        # Role-based validation
        if data['role'] == 'restorer':
            required_fields = ['first_name', 'last_name', 'county', 'subcounty']
            for field in required_fields:
                if not data.get(field):
                    raise serializers.ValidationError({field: f"{field} is required for restorers"})
            
            if 'restoration_type_ids' not in data or not data['restoration_type_ids']:
                raise serializers.ValidationError({"restoration_type_ids": "At least one restoration type is required"})
        
        elif data['role'] == 'organization':
            if not data.get('organization_name'):
                raise serializers.ValidationError({"organization_name": "Organization name is required"})
        
        return data
    
    def create(self, validated_data):
        # Remove fields not in User model
        validated_data.pop('confirm_password')
        restoration_type_ids = validated_data.pop('restoration_type_ids', [])
        
        # Set terms accepted timestamp
        if validated_data.get('terms_accepted'):
            validated_data['terms_accepted_at'] = timezone.now()
        
        # Create user
        user = User.objects.create_user(**validated_data)
        
        # Create user restoration types
        if restoration_type_ids:
            for type_id in restoration_type_ids:
                UserRestorationType.objects.create(
                    user=user,
                    restoration_type_id=type_id
                )
        
        return user


# User Serializer (for responses)
class UserSerializer(serializers.ModelSerializer):
    county_name = serializers.CharField(source='county.name', read_only=True)
    subcounty_name = serializers.CharField(source='subcounty.name', read_only=True)
    restoration_types = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'role', 'first_name', 'last_name', 'phone',
            'county', 'county_name', 'subcounty', 'subcounty_name',
            'organization_name', 'restoration_types', 'created_at'
        ]
    
    def get_restoration_types(self, obj):
        if obj.role == 'restorer':
            user_types = UserRestorationType.objects.filter(user=obj)
            return RestorationTypeSerializer(
                [ut.restoration_type for ut in user_types],
                many=True
            ).data
        return []


# User Profile Update Serializer
class UserProfileUpdateSerializer(serializers.ModelSerializer):
    restoration_type_ids = serializers.ListField(
        child=serializers.IntegerField(),
        write_only=True,
        required=False
    )
    
    class Meta:
        model = User
        fields = [
            'first_name', 'last_name', 'phone', 'email',
            'county', 'subcounty', 'organization_name', 'restoration_type_ids'
        ]
    
    def validate_restoration_type_ids(self, value):
        # Check if user can remove types (no land listings using them)
        user = self.instance
        if user.role == 'restorer':
            current_type_ids = set(
                UserRestorationType.objects.filter(user=user).values_list('restoration_type_id', flat=True)
            )
            new_type_ids = set(value)
            removed_types = current_type_ids - new_type_ids
            
            if removed_types:
                # Check if any land listings use the removed types
                land_listings = LandListing.objects.filter(user=user, is_deleted=False)
                for listing in land_listings:
                    listing_type_ids = set(
                        LandRestorationType.objects.filter(land_listing=listing).values_list('restoration_type_id', flat=True)
                    )
                    conflict_types = removed_types & listing_type_ids
                    if conflict_types:
                        type_names = RestorationType.objects.filter(id__in=conflict_types).values_list('display_name', flat=True)
                        raise serializers.ValidationError(
                            f"Cannot remove restoration types: {', '.join(type_names)}. "
                            "You have land listings using these types."
                        )
        return value
    
    def update(self, instance, validated_data):
        restoration_type_ids = validated_data.pop('restoration_type_ids', None)
        
        # Update user fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Update restoration types if provided
        if restoration_type_ids is not None and instance.role == 'restorer':
            # Delete old types
            UserRestorationType.objects.filter(user=instance).delete()
            # Create new types
            for type_id in restoration_type_ids:
                UserRestorationType.objects.create(
                    user=instance,
                    restoration_type_id=type_id
                )
        
        return instance


# Land Listing Serializer
class LandListingSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    user_email = serializers.EmailField(source='user.email', read_only=True)
    county_name = serializers.CharField(source='county.name', read_only=True)
    subcounty_name = serializers.CharField(source='subcounty.name', read_only=True)
    restoration_types = serializers.SerializerMethodField()
    restoration_type_ids = serializers.ListField(
        child=serializers.IntegerField(),
        write_only=True
    )
    size = serializers.DecimalField(max_digits=10, decimal_places=2, write_only=True)
    unit = serializers.ChoiceField(choices=['acres', 'hectares'], write_only=True)
    
    class Meta:
        model = LandListing
        fields = [
            'id', 'user', 'user_name', 'user_email', 'title',
            'size', 'unit', 'size_acres', 'size_hectares',
            'county', 'county_name', 'subcounty', 'subcounty_name',
            'restoration_type_ids', 'restoration_types',
            'availability', 'image_url', 'created_at', 'updated_at'
        ]
        read_only_fields = ['user', 'size_acres', 'size_hectares']
    
    def get_user_name(self, obj):
        if obj.user.role == 'restorer':
            return f"{obj.user.first_name} {obj.user.last_name}"
        return obj.user.organization_name
    
    def get_restoration_types(self, obj):
        land_types = LandRestorationType.objects.filter(land_listing=obj)
        return RestorationTypeSerializer(
            [lt.restoration_type for lt in land_types],
            many=True
        ).data
    
    def validate_restoration_type_ids(self, value):
        # Check that types are subset of user's types
        request = self.context.get('request')
        if request and request.user:
            user_type_ids = set(
                UserRestorationType.objects.filter(user=request.user).values_list('restoration_type_id', flat=True)
            )
            requested_type_ids = set(value)
            
            if not requested_type_ids.issubset(user_type_ids):
                raise serializers.ValidationError(
                    "You can only select restoration types that you support in your profile"
                )
        return value
    
    def create(self, validated_data):
        from decimal import Decimal
    
        restoration_type_ids = validated_data.pop('restoration_type_ids')
        size = validated_data.pop('size')
        unit = validated_data.pop('unit')
        
        # Convert units (use Decimal for precision)
        conversion_factor = Decimal('0.404686')
        
        if unit == 'acres':
            validated_data['size_acres'] = size
            validated_data['size_hectares'] = round(size * conversion_factor, 2)
        else:
            validated_data['size_hectares'] = size
            validated_data['size_acres'] = round(size / conversion_factor, 2)
        
        # Create land listing
        land_listing = LandListing.objects.create(**validated_data)
        
        # Create restoration types
        for type_id in restoration_type_ids:
            LandRestorationType.objects.create(
                land_listing=land_listing,
                restoration_type_id=type_id
            )
        
        return land_listing
    
    def update(self, instance, validated_data):
        restoration_type_ids = validated_data.pop('restoration_type_ids', None)
        size = validated_data.pop('size', None)
        unit = validated_data.pop('unit', None)
        
        # Convert units if size provided
        # Convert units if size provided
        if size and unit:
            from decimal import Decimal
            conversion_factor = Decimal('0.404686')
            
            if unit == 'acres':
                validated_data['size_acres'] = size
                validated_data['size_hectares'] = round(size * conversion_factor, 2)
            else:
                validated_data['size_hectares'] = size
                validated_data['size_acres'] = round(size / conversion_factor, 2)
        
        # Update fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Update restoration types if provided
        if restoration_type_ids is not None:
            LandRestorationType.objects.filter(land_listing=instance).delete()
            for type_id in restoration_type_ids:
                LandRestorationType.objects.create(
                    land_listing=instance,
                    restoration_type_id=type_id
                )
        
        return instance


# Match Request Serializer
class MatchRequestSerializer(serializers.ModelSerializer):
    organization_name = serializers.CharField(source='organization.organization_name', read_only=True)
    organization_email = serializers.EmailField(source='organization.email', read_only=True)
    restorer_name = serializers.SerializerMethodField()
    restorer_email = serializers.EmailField(source='restorer.email', read_only=True)
    restorer_phone = serializers.CharField(source='restorer.phone', read_only=True)
    land_listing_title = serializers.CharField(source='land_listing.title', read_only=True)
    land_listing_details = serializers.SerializerMethodField()
    
    class Meta:
        model = MatchRequest
        fields = [
            'id', 'organization', 'organization_name', 'organization_email',
            'restorer', 'restorer_name', 'restorer_email', 'restorer_phone',
            'land_listing', 'land_listing_title', 'land_listing_details',
            'status', 'created_at', 'updated_at'
        ]
        read_only_fields = ['organization', 'restorer', 'status']
    
    def get_restorer_name(self, obj):
        return f"{obj.restorer.first_name} {obj.restorer.last_name}"
    
    def get_land_listing_details(self, obj):
        return LandListingSerializer(obj.land_listing, context=self.context).data


# Notification Serializer
class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'type', 'message', 'is_read', 'created_at']
        read_only_fields = ['type', 'message']