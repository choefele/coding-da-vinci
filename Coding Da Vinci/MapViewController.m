//
//  ViewController.m
//  Coding Da Vinci
//
//  Created by Claus Höfele on 27.04.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "MapViewController.h"

#import "ImageAnnotation.h"
#import "ImageAnnotationView.h"

#import <MapKit/MapKit.h>

typedef struct {
    CLLocationCoordinate2D coordinate;
    unsigned int yearConstruction;
    unsigned int yearDemolition;
    char *path;
} ImageLocation;
ImageLocation IMAGE_LOCATIONS[] = {
    {52.505615, 13.339771,     1844, UINT_MAX, "Zoo_Eingang-IV-64-1294-V.jpg"},
    {52.515078, 13.413831, UINT_MAX, UINT_MAX, "Ufer_Stralauer_Strasse-GHZ-78-26.jpg"},
    {52.517666, 13.398577,     1821, UINT_MAX, "Schlossbrücke-VII-62-424-a-W.jpg"},
    {52.518405, 13.408499,     1861, UINT_MAX, "Rathaus-IV-61-1537-S.jpg"},
    {52.517551, 13.396956,     1695, UINT_MAX, "Platz_am_Zeughaus-VII-59-513-x.jpg"},
    {52.516273, 13.377702, UINT_MAX, UINT_MAX, "Panorama_von_Berlin-GDR-64-11-108.jpg"},
    {52.551503, 13.367329,     1900, UINT_MAX, "Nauener_Platz-GHZ-77-13.jpg"},
    {52.513820, 13.414880,     1908, UINT_MAX, "Märkisches_Museum-GE-2007-638-VF.jpg"},
    {52.511931, 13.386628,     1737,     1947, "Mauerstrasse-Dreifaltigkeitskirche-GDR-71-67.jpg"},
    {52.510995, 13.364291,     1809, UINT_MAX, "Luiseninsel_Tiergarten-GDR-76-57-45.jpg"},
    {52.509624, 13.377545,     1732, UINT_MAX, "Leipziger_Platz-GDR-76-57-24.jpg"},
    {52.454568, 13.383504, UINT_MAX, UINT_MAX, "Landwehrkanal-GHZ-90-61.jpg"},             // ?
    {52.523305, 13.430665, UINT_MAX, UINT_MAX, "Landsbergerplatz-IV-61-3475-V.jpg"},       // Platz der Vereinten Nationen
    {52.521357, 13.411971,     1777, UINT_MAX, "Königsstrasse-VII-60-1489-W.jpg"},         // Königskolonnaden Alexanderplatz -> Kleistpark
    {52.514081, 13.405723,     1709,     1900, "Köllnischer_Fischmarkt-VII-59-29-w.jpg"},  // Breite Straße/Mühlendamm, Cöllnisches Rathaus
    {52.503960, 13.395452,     1484, UINT_MAX, "Jerusalemkirche-GHZ-74-14.jpg"},           // Rudi-Dutschke-Str. -> Linden- und Markgrafenstr.
    {52.523649, 13.402032, UINT_MAX, UINT_MAX, "Hackescher_Markt-VII-67-294-W.jpg"},
    {52.478178, 13.196753,     1899, UINT_MAX, "Grunewaldturm-SM-2013-1297.jpg"},
    {52.446822, 13.230031, UINT_MAX, UINT_MAX, "Fischerhütte-SM-2012-2093.jpg"},
    {52.503611, 13.329163,     1892, UINT_MAX, "Filmfestspiele_Kudamm-SM-2013-1519.jpg"},  // Kurfürstendamm 25, Hotel am Zoo (09020713)
    {52.516908, 13.400038,     1443,     1950, "Einzug_des_Königs-GDR-64-11-216.jpg"},     // Schlossplatz, Berliner Schloss
    {52.521816, 13.413037, UINT_MAX, UINT_MAX, "Der_Ochsen-Platz-GDR-64-11-171.jpg"},      // Alexanderplatz
    {52.509511, 13.376649,     1683,     1738, "Das_Leipziger_Tor-GDR-74-55.jpg"},         // Potsdamer Platz/Leipziger Platz
    {52.516280, 13.377695,     1734, UINT_MAX, "Das_Brandenburger_Tor-GDR-65-7-1.jpg"},
    {52.513754, 13.401384, UINT_MAX, UINT_MAX, "Cölln_Jungfernbrücke-GHZ-64-3-13.jpg"},
    {52.520565, 13.401708,     1859,     1945, "Börse-IV-61-1531-S.jpg"},                  // Burgstraße
    {52.502331, 13.446358, UINT_MAX, UINT_MAX, "Blick_von_Oberbaumbrücke-VII-59-408-W.jpg"},
    {52.487625, 13.381483,     1818, UINT_MAX, "Berlin_vom_Kreuzberg_aus-GDR-69-56.jpg"},  // Nationaldenkmal
    {52.501799, 13.278023,     1924, UINT_MAX, "Avus_Funkturm-SM-2013-0958.jpg"},
    {52.527884, 13.373207,     1847, UINT_MAX, "Hamburger_Bahnhof-VII-97-341-a-W.jpg"},
    {52.498995, 13.391758,     1732, UINT_MAX, "Rondell-GHZ-74-12.jpg"}                    // Mehringplatz
};
// Date of building dominating the image
// Panoramas, unknown -> date image

@interface MapViewController ()<MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic) MKTileOverlay *overlay;
@property (nonatomic, getter = isOverlayEnabled) BOOL overlayEnabled;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5233, 13.4127), MKCoordinateSpanMake(0.0493, 0.1366));
    
    // Images
    for (NSUInteger i = 0; i < sizeof(IMAGE_LOCATIONS) / sizeof(ImageLocation); i++) {
        ImageLocation location = IMAGE_LOCATIONS[i];
        ImageAnnotation *annotation = [[ImageAnnotation alloc] init];
        annotation.coordinate = location.coordinate;
        annotation.path = [NSString stringWithUTF8String:location.path];
        [self.mapView addAnnotation:annotation];
    }
    
    // Map overlay
    NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Berlin1650"];
    NSString *tileDirectoryURL = [NSURL fileURLWithPath:tileDirectory isDirectory:YES];
    NSString *tileTemplate = [NSString stringWithFormat:@"%@{z}/{x}/{y}.png", tileDirectoryURL];
    self.overlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
    self.overlay.geometryFlipped = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"identifier";
    MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        ImageAnnotationView *imageAnnotationView = [[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        ImageAnnotation *imageAnnotation = (ImageAnnotation *)annotation;
        UIImage *image = [UIImage imageNamed:imageAnnotation.path];
        imageAnnotationView.image = image;
        annotationView = imageAnnotationView;
    }
    
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
    return renderer;
}

- (IBAction)toggleMap:(UIBarButtonItem *)sender
{
    self.overlayEnabled = !self.isOverlayEnabled;
    if (self.isOverlayEnabled) {
        [self.mapView addOverlay:self.overlay];
    } else {
        [self.mapView removeOverlay:self.overlay];
    }
}

@end
