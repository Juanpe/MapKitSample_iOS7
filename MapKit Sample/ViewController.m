//
//  ViewController.m
//  MapKit Sample
//
//  Created by Juan Pedro Catalán on 11/10/13.
//  Copyright (c) 2013 Juanpe Catalán. All rights reserved.
//

#import "SnapshotViewController.h"
#import "ViewController.h"

@interface ViewController ()

// Coordinates
@property(nonatomic) CLLocationCoordinate2D ElizabethTowerCoords;
@property(nonatomic) CLLocationCoordinate2D LondonCityCoords;
@property(nonatomic) CLLocationCoordinate2D LondonBridgeCoords;
@property(nonatomic) CLLocationCoordinate2D PiccadilyCoords;
@property(nonatomic) CLLocationCoordinate2D NewYorkCoords;

// Polylines
@property(nonatomic, strong) MKPolygon* regionPolygon;
@property(nonatomic, strong) MKPolyline* overlayPolyline;
@property(nonatomic, strong) MKGeodesicPolyline* geodesicPolyline;

// Private methods
- (void) _centerMapWithCoords:(NSArray *) points;
- (void) _drawStandardPolyline;
- (void) _drawGeodesicPolyline;
- (void) _drawRoutePolyline:(MKPolyline *) responsePolyline;
- (void) _findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination onMode:(NSInteger) modeType;
- (CLLocation *) _locationWithCoordinate:(CLLocationCoordinate2D) coord;
- (void) _resetOverlayViews;
- (void) _startStepByStepModeWithSteps:(NSArray *) steps;
- (BOOL) _stepModeDisabled;

@end

// Map types
NSInteger const JCMap2DIndex = 0;
NSInteger const JCMap3DIndex = 1;

// Polyline types
NSInteger const JCPolylineType          = 0;
NSInteger const JCGeodesicPolylineType  = 1;

// ActionSheet tag
NSInteger const JCActionSheetPolyline   = 0;
NSInteger const JCActionSheetRoute      = 1;

// Route type
NSInteger const JCRouteGeneral          = 0;
NSInteger const JCRouteStepByStep       = 1;

@implementation ViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"MapKit Sample"];
    
    //
    // StepVC preload
    //
    self.stepVC                 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"StepViewController"];
    CGRect stepViewFrame        = CGRectMake(0.0f,
                                             -39.0f,
                                             320.0f,
                                             100.0f);
    self.stepVC.view.frame      = stepViewFrame;
    [self.view addSubview:self.stepVC.view];
    
    [self.btnExitStepRoute setHidden:YES];
    
    
    // Config map
    self.mapView.showsBuildings         = YES;
    self.mapView.showsPointsOfInterest  = YES;
   
    //
    // Coords
    //
    
    // Elizabeth Tower
    self.ElizabethTowerCoords   = CLLocationCoordinate2DMake(51.500705, -0.124575);
    
    // London City
    self.LondonCityCoords       = CLLocationCoordinate2DMake(51.511214, -0.119824);
    
    // London Bridge
    self.LondonBridgeCoords     = CLLocationCoordinate2DMake(51.509194, -0.087022);
    
    // Piccadily
    self.PiccadilyCoords        = CLLocationCoordinate2DMake(51.506568, -0.143225);
    
    // New York
    self.NewYorkCoords          = CLLocationCoordinate2DMake(40.714353, -74.005973);
    
    //
    // Centramos el mapa
    //
    [self.mapView showAnnotations:@[[self _locationWithCoordinate:self.LondonCityCoords]]
                         animated:YES];
}

#pragma mark - IBActions
- (IBAction) selectorMapTypeValueChanged:(id)sender {
    
    if ([self _stepModeDisabled]) {
        NSInteger optionSelected    = [((UISegmentedControl *)sender) selectedSegmentIndex];
        
        //
        // Capturamos la cámara que se está usando para modificarla
        // y volverla a añadir. Realmente no sería necesario, ya que
        // podemos crear una desde cero.
        //
        MKMapCamera* currentCamera  = self.mapView.camera;
        
        switch (optionSelected) {
            case JCMap2DIndex:
                currentCamera.pitch     = 0.0f;
                break;
            case JCMap3DIndex:
                currentCamera.altitude  = 200.0f;
                currentCamera.pitch     = 70.0f;
                break;
            default:
                currentCamera.pitch     = 0.0f;
                break;
        }
        
        [self.mapView setCamera:currentCamera
                       animated:YES];
    }
}

- (IBAction) drawRegionWithPointsTouchUpInside{
    
    if ([self _stepModeDisabled]) {
        //
        // Borramos las vistas que estén pintadas
        // en el mapa.
        //
        [self _resetOverlayViews];
        
        //
        // Centramos el mapa para que se vean
        // todos los puntos.
        //
        [self _centerMapWithCoords:@[
                                     [self _locationWithCoordinate:self.LondonBridgeCoords],
                                     [self _locationWithCoordinate:self.LondonCityCoords],
                                     [self _locationWithCoordinate:self.PiccadilyCoords],
                                     [self _locationWithCoordinate:self.ElizabethTowerCoords],
                                     ]];
        
        CLLocationCoordinate2D points[4];
        
        points[0] = self.LondonBridgeCoords;
        points[1] = self.LondonCityCoords;
        points[2] = self.PiccadilyCoords;
        points[3] = self.ElizabethTowerCoords;
        
        //
        // Creamos un polígono con las coordenadas y
        // lo guardamos.
        //
        self.regionPolygon = [MKPolygon polygonWithCoordinates:points
                                                         count:4];
        
        //
        // Lo añadimos al mapa.
        //
        [_mapView addOverlay:self.regionPolygon];
    }
}

- (IBAction) drawPolylineTouchUpInside{
    
    if([self _stepModeDisabled]){
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Draw Polyline", @"Draw Geodesic Polyline", nil];
        actionSheet.tag             = JCActionSheetPolyline;
        
        [actionSheet showInView:self.view];
    }
}

- (IBAction) drawRouteTouchUpInside{
    
    if ([self _stepModeDisabled]) {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"General", @"Step by Step", nil];
        actionSheet.tag             = JCActionSheetRoute;
        
        [actionSheet showInView:self.view];
    }   
}

- (IBAction) exitStepByStepTouchUpInside:(id)sender {
    
    [self.btnExitStepRoute  setHidden:YES];
    [self.mapTypeSelector   setHidden:NO];
    [self.mapTypeSelector   setSelectedSegmentIndex:0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JCChangeStepNotiticationKey
                                                  object:nil];
    
    [self _resetOverlayViews];
    [self.stepVC showStepView:NO];
    
    //
    // Centramos el mapa
    //
    [self.mapView showAnnotations:@[[self _locationWithCoordinate:self.LondonCityCoords]]
                         animated:YES];
}

- (IBAction) takeSnapShotTouchUpInside{
    
    if ([self _stepModeDisabled]) {
        MKMapSnapshotOptions *options   = [[MKMapSnapshotOptions alloc] init];
        options.size                    = CGSizeMake(256, 360);
        options.scale                   = [[UIScreen mainScreen] scale];
        options.camera                  = self.mapView.camera;
        options.mapType                 = MKMapTypeStandard;
        
        MKMapSnapshotter *snapshotter   = [[MKMapSnapshotter alloc] initWithOptions:options];
        
        [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *e)
         {
             if (e) {
                 NSLog(@"Error => %@", e.debugDescription);
             }
             else {
                 
                 SnapshotViewController* snapShotVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"snapshotVC"];
                 
                 [snapShotVC setMapCapture:snapshot];
                 
                 [self.navigationController pushViewController:snapShotVC
                                                      animated:YES];
             }
         }];
    }
}

#pragma mark - Private Methods

- (void) _centerMapWithCoords:(NSArray *) points{

    NSMutableArray* newPoints = [NSMutableArray arrayWithCapacity:points.count];
    
    for (CLLocation *pointLocation in points) {
        
        MKPointAnnotation * point   = [[MKPointAnnotation alloc] init];
        point.coordinate            = pointLocation.coordinate;
        
        [newPoints addObject:point];
    }
    
    [self.mapView showAnnotations:newPoints
                         animated:YES];
}

- (void) _drawStandardPolyline{

    [self _resetOverlayViews];
    
    [self _centerMapWithCoords:@[
                                 [self _locationWithCoordinate:self.LondonCityCoords],
                                 [self _locationWithCoordinate:self.NewYorkCoords],
                                 ]];
    
    CLLocationCoordinate2D points[2];
    
    points[0] = self.LondonCityCoords;
    points[1] = self.NewYorkCoords;
    
    self.overlayPolyline = [MKPolyline polylineWithCoordinates:points
                                                         count:2];
    
    [_mapView addOverlay:self.overlayPolyline];
}

- (void) _drawGeodesicPolyline{
    
    [self _resetOverlayViews];

    [self _centerMapWithCoords:@[
                                 [self _locationWithCoordinate:self.LondonCityCoords],
                                 [self _locationWithCoordinate:self.NewYorkCoords],
                                 ]];
    
    CLLocationCoordinate2D points[2];
    
    points[0] = self.LondonCityCoords;
    points[1] = self.NewYorkCoords;
    
    self.geodesicPolyline = [MKGeodesicPolyline polylineWithCoordinates:points
                                                                  count:2];
    
    [_mapView addOverlay:self.geodesicPolyline];
}

- (void) _drawRoutePolyline:(MKPolyline *) responsePolyline{

    [self _resetOverlayViews];
    
    [self _centerMapWithCoords:@[
                                 [self _locationWithCoordinate:self.LondonBridgeCoords],
                                 [self _locationWithCoordinate:self.PiccadilyCoords],
                                 ]];
    
    [_mapView addOverlay:responsePolyline];
}

- (CLLocation *) _locationWithCoordinate:(CLLocationCoordinate2D) coord{

    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude
                                                      longitude:coord.longitude];
    
    return location;
}

- (void) _findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination onMode:(NSInteger) modeType{
    
    MKDirectionsRequest *request    = [[MKDirectionsRequest alloc] init];
    request.source                  = source;
    request.destination             = destination;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions        = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error => %@", error.debugDescription);
            
        }else {
            
            //
            // Cogemos la primera que nos devuelve
            //
            MKRoute *route = response.routes[0];
            
            if (modeType == JCRouteGeneral) {
                [self _drawRoutePolyline:route.polyline];
            }else{
                [self _startStepByStepModeWithSteps:route.steps];
            }
        }
    }];
}

- (void) _resetOverlayViews{

    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void) _startStepByStepModeWithSteps:(NSArray *) steps{
    
    [self.btnExitStepRoute  setHidden:NO];
    [self.mapTypeSelector   setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeStepNotificaction:)
                                                 name:JCChangeStepNotiticationKey
                                               object:nil];
    
    [self.stepVC setSteps:steps];
    [self.stepVC showStepView:YES];
}

- (BOOL) _stepModeDisabled{

    return (self.stepVC.view.frame.origin.y == -39);
}

#pragma mark - Step Notification 

- (void) changeStepNotificaction:(NSNotification *) notification{

    MKRouteStep* stepObj = (MKRouteStep *)[notification object];
    
    [self _resetOverlayViews];
    
    [_mapView addOverlay:stepObj.polyline];

    if (stepObj.distance != 0) {
        [_mapView setVisibleMapRect:[stepObj.polyline boundingMapRect]
                           animated:YES];
    }
}

#pragma mark - MapKit Delegate Methods

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    UIColor *blueColorTranslucent = [UIColor colorWithRed:0 green:0 blue:255.0f alpha:0.5f];
    
    if(overlay == self.regionPolygon){
        
        //
        // Si pintamos la region, línea azul
        // con grosor de 1 y relleno azul con transparencia.
        //
        
        MKPolygonRenderer *polygonRenderer  = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonRenderer.strokeColor         = [UIColor blueColor];
        polygonRenderer.fillColor           = blueColorTranslucent;
        polygonRenderer.lineWidth           = 1.0f;
        
        return polygonRenderer;
        
    }else if(overlay == self.overlayPolyline || overlay == self.geodesicPolyline){
        
        //
        // Si estamos pintando una línea punto a punto
        // la pintamos de rojo y grosor 3
        //
        
        MKPolylineRenderer *polylineRender  = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRender.lineWidth            = 3.0f;
        UIColor *lineColor                  = [UIColor redColor];
        
        if(overlay == self.overlayPolyline){
            lineColor = [UIColor blackColor];
        }
        polylineRender.strokeColor          = lineColor;
        
        return polylineRender;
        
    }else{
        
        //
        // Pintamos la ruta en azul y grosor 3
        //
        
        MKPolylineRenderer *polylineRender  = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRender.lineWidth            = 3.0f;
        polylineRender.strokeColor          = [UIColor blueColor];
        
        return polylineRender;
    }
    return nil;
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        if (actionSheet.tag == JCActionSheetPolyline) {
        
            if (buttonIndex == JCGeodesicPolylineType) {
                [self _drawGeodesicPolyline];
            }else if(buttonIndex == JCPolylineType){
                [self _drawStandardPolyline];
            }
            
        }else{
        
            //
            // Placemark
            //
            MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.LondonBridgeCoords
                                                               addressDictionary:nil];
            
            MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:self.PiccadilyCoords
                                                               addressDictionary:nil];
            
            //
            // Map Item
            //
            MKMapItem *fromItem         = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
            MKMapItem *toItem           = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
            
            [self _findDirectionsFrom:fromItem
                                   to:toItem
                               onMode:buttonIndex];
        }
    }
}

@end
