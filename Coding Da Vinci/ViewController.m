//
//  ViewController.m
//  Coding Da Vinci
//
//  Created by Claus Höfele on 27.04.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "ViewController.h"

#import "ImageAnnotation.h"
#import "ImageAnnotationView.h"

#import <MapKit/MapKit.h>

typedef struct {
    CLLocationCoordinate2D coordinate;
    char *path;
} ImageLocation;
ImageLocation IMAGE_LOCATIONS[] = {
    {52.505615, 13.339771, "Zoo_Eingang-IV-64-1294-V.jpg"},
    {52.515078, 13.413831, "Ufer_Stralauer_Strasse-GHZ-78-26.jpg"},
    {52.517666, 13.398577, "Schlossbrücke-VII-62-424-a-W.jpg"},
    {52.518405, 13.408499, "Rathaus-IV-61-1537-S.jpg"},
    {52.517551, 13.396956, "Platz_am_Zeughaus-VII-59-513-x.jpg"},
    {52.516273, 13.377702, "Panorama_von_Berlin-GDR-64-11-108.jpg"},
    {52.551503, 13.367329, "Nauener_Platz-GHZ-77-13.jpg"},
    {52.513820, 13.414880, "Märkisches_Museum-GE-2007-638-VF.jpg"},
    {52.511931, 13.386628, "Mauerstrasse-Dreifaltigkeitskirche-GDR-71-67.jpg"},
    {52.510995, 13.364291, "Luiseninsel_Tiergarten-GDR-76-57-45.jpg"},
    {52.509624, 13.377545, "Leipziger_Platz-GDR-76-57-24.jpg"},
    {52.454568, 13.383504, "Landwehrkanal-GHZ-90-61.jpg"},          // ?
    {52.523305, 13.430665, "Landsbergerplatz-IV-61-3475-V.jpg"},    // Platz der Vereinten Nationen
    {52.521357, 13.411971, "Königsstrasse-VII-60-1489-W.jpg"},      // Alexanderplatz
    {52.514081, 13.405723, "Köllnischer_Fischmarkt-VII-59-29-w.jpg"},// Breite Straße/Mühlendamm
    {52.503960, 13.395452, "Jerusalemkirche-GHZ-74-14.jpg"},
    {52.523649, 13.402032, "Hackescher_Markt-VII-67-294-W.jpg"},
    {52.478178, 13.196753, "Grunewaldturm-SM-2013-1297.jpg"},
    {52.446822, 13.230031, "Fischerhütte-SM-2012-2093.jpg"},
    {52.503611, 13.329163, "Filmfestspiele_Kudamm-SM-2013-1519.jpg"},// Kurfürstendamm 25
    {52.516908, 13.400038, "Einzug_des_Königs-GDR-64-11-216.jpg"},  // Schlossplatz?
    {52.521816, 13.413037, "Der_Ochsen-Platz-GDR-64-11-171.jpg"},   // Alexanderplatz
    {52.509511, 13.376649, "Das_Leipziger_Tor-GDR-74-55.jpg"},      // Potsdamer Platz/Leipziger Platz
    {52.516280, 13.377695, "Das_Brandenburger_Tor-GDR-65-7-1.jpg"},
    {52.513754, 13.401384, "Cölln_Jungfernbrücke-GHZ-64-3-13.jpg"},
    {52.520565, 13.401708, "Börse-IV-61-1531-S.jpg"},               // Burgstraße
    {52.502331, 13.446358, "Blick_von_Oberbaumbrücke-VII-59-408-W.jpg"},
    {52.487625, 13.381483, "Berlin_vom_Kreuzberg_aus-GDR-69-56.jpg"},
    {52.501799, 13.278023, "Avus_Funkturm-SM-2013-0958.jpg"},
    {52.527884, 13.373207, "Hamburger_Bahnhof-VII-97-341-a-W.jpg"},
    {52.498995, 13.391758, "Rondell-GHZ-74-12.jpg"}                 // Mehringplatz
};

@interface ViewController ()<MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5233, 13.4127), MKCoordinateSpanMake(0.4493, 0.7366));
    
    for (NSUInteger i = 0; i < sizeof(IMAGE_LOCATIONS) / sizeof(ImageLocation); i++) {
        ImageLocation location = IMAGE_LOCATIONS[i];
        ImageAnnotation *annotation = [[ImageAnnotation alloc] init];
        annotation.coordinate = location.coordinate;
        annotation.path = [NSString stringWithUTF8String:location.path];
        [self.mapView addAnnotation:annotation];
    }
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

@end
