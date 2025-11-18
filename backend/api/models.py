from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils import timezone


# Custom User Manager
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'restorer')  # Default role for superuser
        return self.create_user(email, password, **extra_fields)


# User Model
class User(AbstractUser):
    ROLE_CHOICES = [
        ('restorer', 'Local Restorer'),
        ('organization', 'Partner Organization'),
    ]
    
    username = None  # Remove username field
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)
    
    # Restorer fields
    first_name = models.CharField(max_length=100, blank=True, null=True)
    last_name = models.CharField(max_length=100, blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    county = models.ForeignKey('County', on_delete=models.SET_NULL, null=True, blank=True, related_name='users')
    subcounty = models.ForeignKey('Subcounty', on_delete=models.SET_NULL, null=True, blank=True, related_name='users')
    
    # Organization fields
    organization_name = models.CharField(max_length=255, blank=True, null=True)
    
    # Terms acceptance tracking
    terms_accepted = models.BooleanField(default=False)
    terms_accepted_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['role']
    
    def __str__(self):
        if self.role == 'restorer':
            return f"{self.first_name} {self.last_name} ({self.email})"
        return f"{self.organization_name} ({self.email})"


# County Model
class County(models.Model):
    name = models.CharField(max_length=100, unique=True)
    
    class Meta:
        verbose_name_plural = "Counties"
        ordering = ['name']
    
    def __str__(self):
        return self.name


# Subcounty Model
class Subcounty(models.Model):
    name = models.CharField(max_length=100)
    county = models.ForeignKey(County, on_delete=models.CASCADE, related_name='subcounties')
    
    class Meta:
        verbose_name_plural = "Subcounties"
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.county.name})"


# Restoration Type Model
class RestorationType(models.Model):
    name = models.CharField(max_length=50, unique=True)  # e.g., 'forest'
    display_name = models.CharField(max_length=100)  # e.g., 'Forest Restoration'
    
    class Meta:
        ordering = ['name']
    
    def __str__(self):
        return self.display_name


# User Restoration Types (Many-to-Many)
class UserRestorationType(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='restoration_types')
    restoration_type = models.ForeignKey(RestorationType, on_delete=models.CASCADE)
    
    class Meta:
        unique_together = ('user', 'restoration_type')
    
    def __str__(self):
        return f"{self.user.email} - {self.restoration_type.display_name}"


# Land Listing Model
class LandListing(models.Model):
    AVAILABILITY_CHOICES = [
        ('available', 'Available'),
        ('unavailable', 'Unavailable'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='land_listings')
    title = models.CharField(max_length=255)
    size_acres = models.DecimalField(max_digits=10, decimal_places=2)
    size_hectares = models.DecimalField(max_digits=10, decimal_places=2)
    county = models.ForeignKey(County, on_delete=models.RESTRICT, related_name='land_listings')
    subcounty = models.ForeignKey(Subcounty, on_delete=models.RESTRICT, related_name='land_listings')
    availability = models.CharField(max_length=20, choices=AVAILABILITY_CHOICES, default='available')
    image_url = models.CharField(max_length=500, blank=True, null=True)
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.user.email}"
    
    def soft_delete(self):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save()


# Land Restoration Types (Many-to-Many)
class LandRestorationType(models.Model):
    land_listing = models.ForeignKey(LandListing, on_delete=models.CASCADE, related_name='restoration_types')
    restoration_type = models.ForeignKey(RestorationType, on_delete=models.CASCADE)
    
    class Meta:
        unique_together = ('land_listing', 'restoration_type')
    
    def __str__(self):
        return f"{self.land_listing.title} - {self.restoration_type.display_name}"


# Match Request Model
class MatchRequest(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('declined', 'Declined'),
        ('land_no_longer_available', 'Land No Longer Available'),
    ]
    
    organization = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_requests')
    restorer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_requests')
    land_listing = models.ForeignKey(LandListing, on_delete=models.CASCADE, related_name='match_requests')
    status = models.CharField(max_length=50, choices=STATUS_CHOICES, default='pending')
    
    # Email tracking
    email_sent = models.BooleanField(default=False)
    email_sent_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        unique_together = ('organization', 'land_listing')
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.organization.organization_name} → {self.land_listing.title} ({self.status})"


# Notification Model
class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('new_request', 'New Request'),
        ('request_accepted', 'Request Accepted'),
        ('request_declined', 'Request Declined'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=50, choices=NOTIFICATION_TYPES)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    match_request = models.ForeignKey(MatchRequest, on_delete=models.CASCADE, null=True, blank=True, related_name='notifications')
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.email} - {self.type} - {'Read' if self.is_read else 'Unread'}"