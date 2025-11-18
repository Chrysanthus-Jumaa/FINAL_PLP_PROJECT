from django.contrib import admin
from .models import (
    User, County, Subcounty, RestorationType,
    UserRestorationType, LandListing, LandRestorationType,
    MatchRequest, Notification
)


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['email', 'role', 'first_name', 'last_name', 'organization_name', 'created_at']
    list_filter = ['role', 'terms_accepted']
    search_fields = ['email', 'first_name', 'last_name', 'organization_name']


@admin.register(County)
class CountyAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']
    search_fields = ['name']


@admin.register(Subcounty)
class SubcountyAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'county']
    list_filter = ['county']
    search_fields = ['name']


@admin.register(RestorationType)
class RestorationTypeAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'display_name']


@admin.register(UserRestorationType)
class UserRestorationTypeAdmin(admin.ModelAdmin):
    list_display = ['user', 'restoration_type']
    list_filter = ['restoration_type']


@admin.register(LandListing)
class LandListingAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'size_acres', 'size_hectares', 'county', 'availability', 'is_deleted', 'created_at']
    list_filter = ['availability', 'is_deleted', 'county']
    search_fields = ['title', 'user__email']


@admin.register(LandRestorationType)
class LandRestorationTypeAdmin(admin.ModelAdmin):
    list_display = ['land_listing', 'restoration_type']
    list_filter = ['restoration_type']


@admin.register(MatchRequest)
class MatchRequestAdmin(admin.ModelAdmin):
    list_display = ['organization', 'restorer', 'land_listing', 'status', 'email_sent', 'created_at']
    list_filter = ['status', 'email_sent']
    search_fields = ['organization__email', 'restorer__email', 'land_listing__title']


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['user', 'type', 'is_read', 'created_at']
    list_filter = ['type', 'is_read']
    search_fields = ['user__email', 'message']