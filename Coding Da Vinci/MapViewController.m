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
#import "ImageViewController.h"

#import <MapKit/MapKit.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>

typedef struct {
    CLLocationCoordinate2D coordinate;
    NSUInteger yearConstruction;
    NSUInteger yearDemolition;
    char *path;
} ImageLocation;
ImageLocation IMAGE_LOCATIONS[] = {
    {52.505615, 13.339771, 1844, NSUIntegerMax, "Zoo_Eingang-IV-64-1294-V.jpg"},
    {52.515078, 13.413831, 1890, NSUIntegerMax, "Ufer_Stralauer_Strasse-GHZ-78-26.jpg"},    // §
    {52.517666, 13.398577, 1821, NSUIntegerMax, "Schlossbrücke-VII-62-424-a-W.jpg"},
    {52.518405, 13.408499, 1861, NSUIntegerMax, "Rathaus-IV-61-1537-S.jpg"},
    {52.517551, 13.396956, 1695, NSUIntegerMax, "Platz_am_Zeughaus-VII-59-513-x.jpg"},
    {52.516273, 13.377702, 1851, NSUIntegerMax, "Panorama_von_Berlin-GDR-64-11-108.jpg"},   // §
    {52.551503, 13.367329, 1900, NSUIntegerMax, "Nauener_Platz-GHZ-77-13.jpg"},
    {52.513820, 13.414880, 1908, NSUIntegerMax, "Märkisches_Museum-GE-2007-638-VF.jpg"},
    {52.511931, 13.386628, 1737,          1947, "Mauerstrasse-Dreifaltigkeitskirche-GDR-71-67.jpg"},
    {52.510995, 13.364291, 1809, NSUIntegerMax, "Luiseninsel_Tiergarten-GDR-76-57-45.jpg"},
    {52.509624, 13.377545, 1732, NSUIntegerMax, "Leipziger_Platz-GDR-76-57-24.jpg"},
    {52.454568, 13.383504, 1900, NSUIntegerMax, "Landwehrkanal-GHZ-90-61.jpg"},             // §, ?
    {52.523305, 13.430665, 1900, NSUIntegerMax, "Landsbergerplatz-IV-61-3475-V.jpg"},       // §, Platz der Vereinten Nationen
    {52.521357, 13.411971, 1777, NSUIntegerMax, "Königsstrasse-VII-60-1489-W.jpg"},         // Königskolonnaden Alexanderplatz -> Kleistpark
    {52.514081, 13.405723, 1709,          1900, "Köllnischer_Fischmarkt-VII-59-29-w.jpg"},  // Breite Straße/Mühlendamm, Cöllnisches Rathaus
    {52.503960, 13.395452, 1484, NSUIntegerMax, "Jerusalemkirche-GHZ-74-14.jpg"},           // Rudi-Dutschke-Str. -> Linden- und Markgrafenstr.
    {52.523649, 13.402032, 1787, NSUIntegerMax, "Hackescher_Markt-VII-67-294-W.jpg"},       // §
    {52.478178, 13.196753, 1899, NSUIntegerMax, "Grunewaldturm-SM-2013-1297.jpg"},
    {52.446822, 13.230031, 1910, NSUIntegerMax, "Fischerhütte-SM-2012-2093.jpg"},           // §
    {52.503611, 13.329163, 1892, NSUIntegerMax, "Filmfestspiele_Kudamm-SM-2013-1519.jpg"},  // Kurfürstendamm 25, Hotel am Zoo (09020713)
    {52.516908, 13.400038, 1443,          1950, "Einzug_des_Königs-GDR-64-11-216.jpg"},     // Schlossplatz, Berliner Schloss
    {52.521816, 13.413037, 1790, NSUIntegerMax, "Der_Ochsen-Platz-GDR-64-11-171.jpg"},      // §, Alexanderplatz
    {52.509511, 13.376649, 1683,          1738, "Das_Leipziger_Tor-GDR-74-55.jpg"},         // Potsdamer Platz/Leipziger Platz
    {52.516280, 13.377695, 1734, NSUIntegerMax, "Das_Brandenburger_Tor-GDR-65-7-1.jpg"},
    {52.513754, 13.401384, 1690, NSUIntegerMax, "Cölln_Jungfernbrücke-GHZ-64-3-13.jpg"},    // §
    {52.520565, 13.401708, 1859,          1945, "Börse-IV-61-1531-S.jpg"},                  // Burgstraße
    {52.502331, 13.446358, 1860, NSUIntegerMax, "Blick_von_Oberbaumbrücke-VII-59-408-W.jpg"},// §
    {52.487625, 13.381483, 1818, NSUIntegerMax, "Berlin_vom_Kreuzberg_aus-GDR-69-56.jpg"},  // Nationaldenkmal
    {52.501799, 13.278023, 1924, NSUIntegerMax, "Avus_Funkturm-SM-2013-0958.jpg"},
    {52.527884, 13.373207, 1847, NSUIntegerMax, "Hamburger_Bahnhof-VII-97-341-a-W.jpg"},
    {52.498995, 13.391758, 1732, NSUIntegerMax, "Rondell-GHZ-74-12.jpg"}                    // Mehringplatz
};
// Date of building dominating the image
// Panoramas, unknown -> date image (§)

@interface MapViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;

@property (nonatomic) MKTileOverlay *overlay;
@property (nonatomic, getter = isOverlayEnabled) BOOL overlayEnabled;
@property (nonatomic, copy) NSArray *allAnnotations;
@property (nonatomic) NSMutableSet *currentAnnotations;
@property (nonatomic, copy) NSArray *allGeometries;
@property (nonatomic, getter = areGeometriesEnabled) BOOL geometriesEnabled;
@property (nonatomic) UIPopoverController *myPopoverController;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5233, 13.4127), MKCoordinateSpanMake(0.0493, 0.1366));
    
    [self setUpAnnotations];
    [self updateAnnotations];
    
    [self setUpOverlay];
    [self updateOverlay];
    
    [self setUpGeometries];
    [self updateGeometries];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.myPopoverController dismissPopoverAnimated:YES];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    return [self imageAnnotationViewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    [self animateInAnnotationViews:annotationViews];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView
{
    [self didSelectAnnotationView:annotationView];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer;
    
    if ([overlay isKindOfClass:MKTileOverlay.class]) {
        renderer = [self tileOverlayRendererForOverlay:overlay];
    } else if ([overlay isKindOfClass:MKPolygon.class]) {
        renderer = [self polygonRendererForOverlay:overlay];
    }
    
    return renderer;
}

#pragma mark Image Annotations

- (void)setUpAnnotations
{
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSUInteger i = 0; i < sizeof(IMAGE_LOCATIONS) / sizeof(ImageLocation); i++) {
        ImageLocation imageLocation = IMAGE_LOCATIONS[i];
        ImageAnnotation *annotation = [[ImageAnnotation alloc] init];
        annotation.coordinate = imageLocation.coordinate;
        annotation.imageFilePath = [NSString stringWithUTF8String:imageLocation.path];
        annotation.yearConstruction = imageLocation.yearConstruction;
        annotation.yearDemolition = imageLocation.yearDemolition;
        
        [annotations addObject:annotation];
    }
    self.allAnnotations = annotations;
    self.currentAnnotations = [NSMutableSet set];
}

- (void)updateAnnotations
{
    NSUInteger year = (NSUInteger)self.timeSlider.value;
    
    // Remove map annotations
    NSArray *currentAnnotations = [self.currentAnnotations copy];
    for (ImageAnnotation *annotation in currentAnnotations) {
        if (![annotation isAvailableInYear:year]) {
            [self.currentAnnotations removeObject:annotation];
            
            // Animate annotations that get removed
            [UIView animateWithDuration:0.5 animations:^{
                MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];
                annotationView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.mapView removeAnnotation:annotation];
            }];
        }
    }
    
    // Add available annotations
    for (ImageAnnotation *annotation in self.allAnnotations) {
        if ([annotation isAvailableInYear:year]) {
            [self.currentAnnotations addObject:annotation];
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (IBAction)timeChanged:(UISlider *)sender
{
    [self updateAnnotations];
}

- (MKAnnotationView *)imageAnnotationViewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"identifier";
    
    ImageAnnotationView *imageAnnotationView = (ImageAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (imageAnnotationView == nil) {
        imageAnnotationView = [[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    ImageAnnotation *imageAnnotation = (ImageAnnotation *)annotation;
    UIImage *image = [UIImage imageNamed:imageAnnotation.imageFilePath];
    imageAnnotationView.image = image;
    
    return imageAnnotationView;
}

- (void)animateInAnnotationViews:(NSArray *)annotationViews
{
    for (MKAnnotationView *annotationView in annotationViews)
    {
        annotationView.alpha = 0.0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        for (MKAnnotationView *annotationView in annotationViews) {
            annotationView.alpha = 1.0;
        }
    }];
}

- (void)didSelectAnnotationView:(MKAnnotationView *)view
{
    [self.mapView deselectAnnotation:view.annotation animated:NO];

    ImageAnnotation *imageAnnotation = (ImageAnnotation *)view.annotation;
    UIImage *image = [UIImage imageNamed:imageAnnotation.imageFilePath];
    
    ImageViewController *imageViewController = (ImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    imageViewController.image = image;
    self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:imageViewController];
    [self.myPopoverController presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark Map Overlay

- (void)setUpOverlay
{
    NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Berlin1650"];
    NSString *tileDirectoryURL = [NSURL fileURLWithPath:tileDirectory isDirectory:YES];
    NSString *tileTemplate = [NSString stringWithFormat:@"%@{z}/{x}/{y}.png", tileDirectoryURL];
    self.overlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
    self.overlay.geometryFlipped = YES;
}

- (void)updateOverlay
{
    if (self.isOverlayEnabled) {
        [self.mapView addOverlay:self.overlay];
    } else {
        [self.mapView removeOverlay:self.overlay];
    }
}

- (IBAction)toggleMap:(UIBarButtonItem *)sender
{
    self.overlayEnabled = !self.isOverlayEnabled;
    [self updateOverlay];
}

- (MKTileOverlayRenderer *)tileOverlayRendererForOverlay:(id<MKOverlay>)overlay
{
    MKTileOverlayRenderer *overlayRenderer = [[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
    return overlayRenderer;
}

#pragma mark Geometries

- (void)setUpGeometries
{
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Berlin" withExtension:@"geojson"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSDictionary *geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self.allGeometries = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:geoJSON error:nil];
}

- (void)updateGeometries
{
    if (self.areGeometriesEnabled) {
        [self.mapView addOverlays:self.allGeometries];
    } else {
        [self.mapView removeOverlays:self.allGeometries];
    }
}

- (IBAction)toggleGeometries:(UIBarButtonItem *)sender
{
    self.geometriesEnabled = !self.areGeometriesEnabled;
    [self updateGeometries];
}

- (MKPolygonRenderer *)polygonRendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolygon *polygon = (MKPolygon *)overlay;
    MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithOverlay:polygon];
    polygonRenderer.strokeColor = UIColor.blueColor;
    polygonRenderer.lineWidth = 1;
    
    return polygonRenderer;
}

@end
