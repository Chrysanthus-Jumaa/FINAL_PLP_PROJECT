from django.urls import path
from . import views

urlpatterns = [
    # Authentication
    #path('seed-database/', views.seed_database, name='seed_database'),
    path('register/', views.register, name='register'),
    path('login/', views.login, name='login'),
    path('profile/', views.get_user_profile, name='get_user_profile'),
    path('profile/update/', views.update_user_profile, name='update_user_profile'),
    
    # Reference Data
    path('counties/', views.get_counties, name='get_counties'),
    path('counties/<int:county_id>/subcounties/', views.get_subcounties, name='get_subcounties'),
    path('restoration-types/', views.get_restoration_types, name='get_restoration_types'),
    
    # Land Listings
    path('lands/', views.LandListingListCreateView.as_view(), name='land_listing_list_create'),
    path('lands/<int:pk>/', views.LandListingDetailView.as_view(), name='land_listing_detail'),
    
    # Match Requests
    path('match-requests/', views.get_match_requests, name='get_match_requests'),
    path('match-requests/create/', views.create_match_request, name='create_match_request'),
    path('match-requests/<int:request_id>/', views.get_match_request_detail, name='get_match_request_detail'),
    path('match-requests/<int:request_id>/update-status/', views.update_match_request_status, name='update_match_request_status'),
    
    # Notifications
    path('notifications/', views.get_notifications, name='get_notifications'),
    path('notifications/<int:notification_id>/mark-read/', views.mark_notification_read, name='mark_notification_read'),
]