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
#import <MKPolygon-GPC/MKPolygon+GPC.h>
#import <ASValueTrackingSlider/ASValueTrackingSlider.h>

typedef struct {
    CLLocationCoordinate2D coordinate;
    NSUInteger yearConstruction;
    NSUInteger yearDemolition;
    char *path;
} ImageAnnotationData;
ImageAnnotationData IMAGE_ANNOTATIONS[] = {
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
    {52.498995, 13.391758, 1732, NSUIntegerMax, "Rondell-GHZ-74-12.jpg"},                   // Mehringplatz
    {52.490886, 13.382603, 1887, NSUIntegerMax, "926px-Blick_auf_Kreuzberg_aus_Großbeerenstraße,_1887.jpg"}
};
// Date of building dominating the image
// Panoramas, unknown -> date image (§)

typedef struct {
    NSUInteger year;
    char *path;
} MapOverlayData;
MapOverlayData MAP_OVERLAYS[] = {
    {1400, "Berlin1650"},
    {1690, "Berlin1690"},
    {1750, "Berlin1750"},
    {1800, "Berlin1800"}
};

typedef struct {
    NSUInteger year;
    char *path;
} GeometryData;
GeometryData GEOMETRIES[] = {
    {1400, "Berlin1650"},
    {1690, "Berlin1690"},
    {1750, "Berlin1750"},
    {1800, "Berlin-heute"}
};

@interface MapViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *timeSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;

@property (nonatomic, copy) NSArray *allImageAnnotations;
@property (nonatomic) NSMutableSet *currentImageAnnotations;
@property (nonatomic, getter = areImageAnnotationsEnabled) BOOL imageAnnotationsEnabled;
@property (nonatomic) UIPopoverController *myPopoverController;

@property (nonatomic) MKTileOverlay *mapOverlay;
@property (nonatomic, getter = isMapOverlayEnabled) BOOL mapOverlayEnabled;
@property (nonatomic) NSString *currentMapOverlayPath;

@property (nonatomic) MKPolygon *geometry;
@property (nonatomic, getter = areGeometriesEnabled) BOOL geometriesEnabled;
@property (nonatomic) NSString *currentGeometryPath;

@property (nonatomic) NSMutableArray *coordinates;
@property (nonatomic) MKPolyline *polyLine;
@property (nonatomic) MKPointAnnotation *previousAnnotation;
@property (nonatomic, getter = isEditing) BOOL editing;
@property (nonatomic) MKPolygon *currentPolygon;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5233, 13.4127), MKCoordinateSpanMake(0.0493, 0.1366));
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 0;
    formatter.minimumFractionDigits = 0;
    formatter.usesGroupingSeparator = NO;
    self.timeSlider.numberFormatter = formatter;
    self.timeSlider.popUpViewColor = UIColor.grayColor;
    
    self.imageAnnotationsEnabled = YES;
    [self setUpImageAnnotations];
    [self updateImageAnnotations];
    
    [self setUpMapOverlay];
    [self updateMapOverlay];
    
    [self setUpGeometries];
    [self updateGeometries];
    self.coordinates = [NSMutableArray array];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.myPopoverController dismissPopoverAnimated:YES];
}

- (void)writeShape:(MKShape *)shape toFileWithName:(NSString *)fileName
{
    NSDictionary *json = [GeoJSONSerialization GeoJSONFeatureFromShape:shape properties:nil error:NULL];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:NULL];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[dirPaths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    [jsonData writeToFile:filePath atomically:YES];
}

- (NSUInteger)year
{
    NSUInteger year = (NSUInteger)self.timeSlider.value;
    return year;
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    if ([annotation isKindOfClass:ImageAnnotation.class]) {
        annotationView = [self imageAnnotationViewForAnnotation:annotation];
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    [self animateInAnnotationViews:annotationViews];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView
{
    [self didSelectImageAnnotationView:annotationView];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer;
    
    if ([overlay isKindOfClass:MKTileOverlay.class]) {
        renderer = [self tileOverlayRendererForOverlay:overlay];
    } else if ([overlay isKindOfClass:MKPolygon.class]) {
        renderer = [self polygonRendererForOverlay:overlay];
    } else if ([overlay isKindOfClass:MKPolyline.class]) {
        renderer = [self polylineRendererForOverlay:overlay];
    }

    return renderer;
}

#pragma mark Animations

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

- (void)animateOutAnnotation:(id<MKAnnotation>)annotation
{
    [UIView animateWithDuration:0.5 animations:^{
        MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];
        annotationView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.mapView removeAnnotation:annotation];
    }];
}

#pragma mark Image Annotations

- (void)setUpImageAnnotations
{
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSUInteger i = 0; i < sizeof(IMAGE_ANNOTATIONS) / sizeof(ImageAnnotationData); i++) {
        ImageAnnotationData imageAnnotationData = IMAGE_ANNOTATIONS[i];
        ImageAnnotation *annotation = [[ImageAnnotation alloc] init];
        annotation.coordinate = imageAnnotationData.coordinate;
        annotation.imageFilePath = [NSString stringWithUTF8String:imageAnnotationData.path];
        annotation.yearConstruction = imageAnnotationData.yearConstruction;
        annotation.yearDemolition = imageAnnotationData.yearDemolition;
        
        if ([annotation.imageFilePath hasPrefix:@"926px-Blick_auf_Kreuzberg"]) {
            annotation.alternativeImageFilePath = @"954px-Blick_auf_Kreuzberg_aus_Großbeerenstraße,_2007.jpg";
        }
        
        [annotations addObject:annotation];
    }
    self.allImageAnnotations = annotations;
    self.currentImageAnnotations = [NSMutableSet set];
}

- (void)updateImageAnnotations
{
    if (self.areImageAnnotationsEnabled) {
        // Remove outdated map annotations
        NSArray *currentAnnotations = [self.currentImageAnnotations copy];
        for (ImageAnnotation *annotation in currentAnnotations) {
            if (![annotation isAvailableInYear:self.year]) {
                [self.currentImageAnnotations removeObject:annotation];
                [self animateOutAnnotation:annotation];
            }
        }
        
        // Add available annotations
        for (ImageAnnotation *annotation in self.allImageAnnotations) {
            if ([annotation isAvailableInYear:self.year]) {
                [self.currentImageAnnotations addObject:annotation];
                [self.mapView addAnnotation:annotation];
            }
        }
    } else {
        // Remove all annotations
        NSArray *currentAnnotations = [self.currentImageAnnotations copy];
        for (ImageAnnotation *annotation in currentAnnotations) {
            [self.currentImageAnnotations removeObject:annotation];
            [self animateOutAnnotation:annotation];
        }
    }
}

- (IBAction)toggleImageAnnotations:(UIBarButtonItem *)sender
{
    self.imageAnnotationsEnabled = !self.areImageAnnotationsEnabled;
    [self updateImageAnnotations];
}

- (IBAction)timeChanged:(UISlider *)sender
{
    [self updateImageAnnotations];
    [self updateMapOverlay];
    [self updateGeometries];
}

- (MKAnnotationView *)imageAnnotationViewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"identifier";
    
    ImageAnnotationView *imageAnnotationView = (ImageAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (imageAnnotationView == nil) {
        imageAnnotationView = [[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    ImageAnnotation *imageAnnotation = (ImageAnnotation *)annotation;
    imageAnnotationView.image = [UIImage imageNamed:imageAnnotation.imageFilePath];
    
    return imageAnnotationView;
}

- (void)didSelectImageAnnotationView:(MKAnnotationView *)view
{
    [self.mapView deselectAnnotation:view.annotation animated:NO];

    ImageAnnotation *imageAnnotation = (ImageAnnotation *)view.annotation;
    
    ImageViewController *imageViewController = (ImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    imageViewController.image = [UIImage imageNamed:imageAnnotation.imageFilePath];
    if (imageAnnotation.alternativeImageFilePath) {
        imageViewController.targetImage = [UIImage imageNamed:imageAnnotation.alternativeImageFilePath];
    }
    self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:imageViewController];
    [self.myPopoverController presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark Map Overlay

- (void)setUpMapOverlay
{
}

- (void)updateMapOverlay
{
    if (self.isMapOverlayEnabled) {
        NSString *path;
        for (NSUInteger i = 0; i < sizeof(MAP_OVERLAYS) / sizeof(MapOverlayData); i++) {
            MapOverlayData mapOverlayData = MAP_OVERLAYS[i];
            if (mapOverlayData.year > self.year) {
                break;
            }
            
            path = [NSString stringWithUTF8String:mapOverlayData.path];
        }
        
        if (![path isEqualToString:self.currentMapOverlayPath]) {
            [self.mapView removeOverlay:self.mapOverlay];
            self.currentMapOverlayPath = path;

            NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
            NSURL *tileDirectoryURL = [NSURL fileURLWithPath:tileDirectory isDirectory:YES];
            NSString *tileTemplate = [NSString stringWithFormat:@"%@{z}/{x}/{y}.png", tileDirectoryURL];
            self.mapOverlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
            self.mapOverlay.geometryFlipped = YES;
            
            [self.mapView addOverlay:self.mapOverlay];
        }
    } else {
        self.currentMapOverlayPath = nil;
        [self.mapView removeOverlay:self.mapOverlay];
    }
}

- (IBAction)toggleMapOverlay:(UIBarButtonItem *)sender
{
    self.mapOverlayEnabled = !self.isMapOverlayEnabled;
    [self updateMapOverlay];
}

- (MKTileOverlayRenderer *)tileOverlayRendererForOverlay:(id<MKOverlay>)overlay
{
    MKTileOverlayRenderer *overlayRenderer = [[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
    return overlayRenderer;
}

#pragma mark Geometries

- (void)setUpGeometries
{
//    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Berlin-Ortsteile" withExtension:@"geojson"];
//    NSData *data = [NSData dataWithContentsOfURL:URL];
//    NSDictionary *geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSArray *geometries = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:geoJSON error:nil];
//
//    MKPolygon *unionPolygon = geometries[0];
//    for (MKPolygon *polygon in geometries) {
//        unionPolygon  = [unionPolygon polygonFromUnionWithPolygon:polygon];
//    }
}

- (void)updateGeometries
{
    if (self.areGeometriesEnabled) {
        NSString *path;
        for (NSUInteger i = 0; i < sizeof(GEOMETRIES) / sizeof(GeometryData); i++) {
            GeometryData geometryData = GEOMETRIES[i];
            if (geometryData.year > self.year) {
                break;
            }
            
            path = [NSString stringWithUTF8String:geometryData.path];
        }
        
        if (![path isEqualToString:self.currentGeometryPath]) {
            [self.mapView removeOverlay:self.geometry];
            self.currentGeometryPath = path;
            
            NSURL *URL = [[NSBundle mainBundle] URLForResource:path withExtension:@"geojson"];
            NSData *data = [NSData dataWithContentsOfURL:URL];
            NSDictionary *geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            MKShape *geometry = [GeoJSONSerialization shapeFromGeoJSONFeature:geoJSON error:NULL];
            self.geometry = (MKPolygon *)geometry;
            
            [self.mapView addOverlay:self.self.geometry];
        }
    } else {
        self.currentGeometryPath = nil;
        [self.mapView removeOverlay:self.geometry];
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

#pragma mark Editing

- (IBAction)toggleEditing:(UIBarButtonItem *)sender
{
    if (!self.isEditing)
    {
        self.editing = YES;
        self.mapView.userInteractionEnabled = NO;
        self.editBarButtonItem.title = @"Fertig";
    }
    else
    {
        self.editing = NO;
        self.mapView.userInteractionEnabled = YES;
        self.editBarButtonItem.title = @"Editieren";

        NSInteger numberOfPoints = [self.coordinates count];
        if (numberOfPoints > 2)
        {
            CLLocationCoordinate2D points[numberOfPoints];
            for (NSInteger i = 0; i < numberOfPoints; i++) {
                points[i] = [self.coordinates[i] MKCoordinateValue];
            }
            MKPolygon *polygon = [MKPolygon polygonWithCoordinates:points count:numberOfPoints];
            [self.mapView removeOverlay:self.currentPolygon];
            [self.mapView addOverlay:polygon];
            [self writeShape:polygon toFileWithName:@"Shape.geojson"];
            
            self.currentPolygon = polygon;
        }
        
        if (self.polyLine) {
            [self.mapView removeOverlay:self.polyLine];
        }
        
        if (self.previousAnnotation) {
            [self.mapView removeAnnotation:self.previousAnnotation];
        }
    }
}

- (void)addCoordinate:(CLLocationCoordinate2D)coordinate replaceLastObject:(BOOL)replaceLast
{
    if (replaceLast && [self.coordinates count] > 0) {
        [self.coordinates removeLastObject];
    }
    
    [self.coordinates addObject:[NSValue valueWithMKCoordinate:coordinate]];
    
    NSInteger numberOfPoints = [self.coordinates count];
    if (numberOfPoints > 1)
    {
        MKPolyline *oldPolyLine = self.polyLine;
        CLLocationCoordinate2D points[numberOfPoints];
        for (NSInteger i = 0; i < numberOfPoints; i++) {
            points[i] = [self.coordinates[i] MKCoordinateValue];
        }
        MKPolyline *newPolyLine = [MKPolyline polylineWithCoordinates:points count:numberOfPoints];
        [self.mapView addOverlay:newPolyLine];
        self.polyLine = newPolyLine;
        
        // note, remove old polyline _after_ adding new one, to avoid flickering effect
        if (oldPolyLine) {
            [self.mapView removeOverlay:oldPolyLine];
        }
        
    }
    
    MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc] init];
    newAnnotation.coordinate = coordinate;
    [self.mapView addAnnotation:newAnnotation];
    
    if (self.previousAnnotation) {
        [self.mapView removeAnnotation:self.previousAnnotation];
    }
    self.previousAnnotation = newAnnotation;
}

- (BOOL)isClosingPolygonWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    BOOL result = NO;
    
    if (self.coordinates.count > 2)
    {
        CLLocationCoordinate2D startCoordinate = [self.coordinates[0] MKCoordinateValue];
        CGPoint start = [self.mapView convertCoordinate:startCoordinate toPointToView:self.mapView];
        CGPoint end = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
        CGFloat xDiff = end.x - start.x;
        CGFloat yDiff = end.y - start.y;
        CGFloat distance = sqrtf(xDiff * xDiff + yDiff * yDiff);
        result = (distance < 30.0);
    }
    
    return result;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isEditing) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self addCoordinate:coordinate replaceLastObject:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isEditing) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self addCoordinate:coordinate replaceLastObject:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isEditing) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self addCoordinate:coordinate replaceLastObject:YES];
    
    // Detect if this coordinate is close enough to starting coordinate to qualify as closing the polygon
    if ([self isClosingPolygonWithCoordinate:coordinate]) {
        [self.coordinates removeLastObject];
        [self toggleEditing:nil];
    }
}

- (MKPolylineRenderer *)polylineRendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolygon *polygon = (MKPolygon *)overlay;
    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:polygon];
    polylineRenderer.strokeColor = UIColor.blueColor;
    polylineRenderer.lineWidth = 1;
    
    return polylineRenderer;
}

@end
