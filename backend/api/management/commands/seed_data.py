from django.core.management.base import BaseCommand
from api.models import County, Subcounty, RestorationType


class Command(BaseCommand):
    help = 'Seeds the database with counties, subcounties, and restoration types'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding restoration types...')
        self.seed_restoration_types()
        
        self.stdout.write('Seeding counties...')
        self.seed_counties()
        
        self.stdout.write('Seeding subcounties...')
        self.seed_subcounties()
        
        self.stdout.write(self.style.SUCCESS('Successfully seeded all data!'))

    def seed_restoration_types(self):
        types = [
            {'name': 'forest', 'display_name': 'Forest Restoration'},
            {'name': 'agroforestry', 'display_name': 'Agroforestry'},
            {'name': 'wetlands', 'display_name': 'Wetlands'},
            {'name': 'mangroves', 'display_name': 'Mangroves'},
        ]
        
        for type_data in types:
            RestorationType.objects.get_or_create(**type_data)
        
        self.stdout.write(self.style.SUCCESS(f'Created {len(types)} restoration types'))

    def seed_counties(self):
        counties = [
            'Baringo', 'Bomet', 'Bungoma', 'Busia', 'Elgeyo-Marakwet',
            'Embu', 'Garissa', 'Homa Bay', 'Isiolo', 'Kajiado',
            'Kakamega', 'Kericho', 'Kiambu', 'Kilifi', 'Kirinyaga',
            'Kisii', 'Kisumu', 'Kitui', 'Kwale', 'Laikipia',
            'Lamu', 'Machakos', 'Makueni', 'Mandera', 'Marsabit',
            'Meru', 'Migori', 'Mombasa', 'Murang\'a', 'Nairobi',
            'Nakuru', 'Nandi', 'Narok', 'Nyamira', 'Nyandarua',
            'Nyeri', 'Samburu', 'Siaya', 'Taita-Taveta', 'Tana River',
            'Tharaka-Nithi', 'Trans-Nzoia', 'Turkana', 'Uasin Gishu', 'Vihiga',
            'Wajir', 'West Pokot'
        ]
        
        for county_name in counties:
            County.objects.get_or_create(name=county_name)
        
        self.stdout.write(self.style.SUCCESS(f'Created {len(counties)} counties'))

    def seed_subcounties(self):
        # Sample subcounties for major counties (you can expand this)
        subcounties_data = {
            'Nairobi': ['Westlands', 'Dagoretti North', 'Dagoretti South', 'Langata', 'Kibra', 
                       'Roysambu', 'Kasarani', 'Ruaraka', 'Embakasi South', 'Embakasi North',
                       'Embakasi Central', 'Embakasi East', 'Embakasi West', 'Makadara', 
                       'Kamukunji', 'Starehe', 'Mathare'],
            'Mombasa': ['Changamwe', 'Jomvu', 'Kisauni', 'Nyali', 'Likoni', 'Mvita'],
            'Kisumu': ['Kisumu East', 'Kisumu West', 'Kisumu Central', 'Seme', 'Nyando', 'Muhoroni', 'Nyakach'],
            'Nakuru': ['Nakuru Town East', 'Nakuru Town West', 'Njoro', 'Molo', 'Gilgil', 'Naivasha', 
                      'Kuresoi South', 'Kuresoi North', 'Subukia', 'Rongai', 'Bahati'],
            'Kiambu': ['Kiambu', 'Thika Town', 'Ruiru', 'Juja', 'Gatundu South', 'Gatundu North',
                      'Githunguri', 'Kikuyu', 'Limuru', 'Kabete', 'Lari', 'Kiambaa'],
            'Machakos': ['Machakos Town', 'Mavoko', 'Kathiani', 'Yatta', 'Kangundo', 'Matungulu', 'Mwala', 'Masinga'],
            'Kakamega': ['Lugari', 'Likuyani', 'Malava', 'Lurambi', 'Navakholo', 'Mumias West', 
                        'Mumias East', 'Matungu', 'Butere', 'Khwisero', 'Shinyalu', 'Ikolomani'],
        }
        
        count = 0
        for county_name, subcounties in subcounties_data.items():
            try:
                county = County.objects.get(name=county_name)
                for subcounty_name in subcounties:
                    Subcounty.objects.get_or_create(name=subcounty_name, county=county)
                    count += 1
            except County.DoesNotExist:
                self.stdout.write(self.style.WARNING(f'County {county_name} not found'))
        
        self.stdout.write(self.style.SUCCESS(f'Created {count} subcounties'))