//
//  ViewController.swift
//  Travel Map Book
//
//  Created by Eloy on 20/07/2017.
//  Copyright © 2017 ERH. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import AudioToolbox

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var distanceToPlace: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveDeleteButton: UIButton!
    
    
    var locationManager = CLLocationManager()
    
    var chosenLatitude : Double = 0
    var chosenLongitude : Double = 0
    
    //Transmited variables, to transmit the values of the variables between the viewcontrollers
    
    var transmittedTitle = ""
    var transmittedSubtitle = ""
    var transmittedLatitude : Double = 0
    var transmittedLongitude : Double = 0
    var transmittedDistance = ""
    
    var requestCLLocation = CLLocation()
    
    var distanceInMeters : Double = 0
    
    var buttonClicked = false
    
    var vibrationOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mapView and location attributes here
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //Estos son los que permiten que salgan las notificaciones del plist.
        //locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Create gesture recognizer
        
        let recognizer = UILongPressGestureRecognizer(target: self, action:#selector(ViewController.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(recognizer)
        
        if (transmittedTitle != ""){
            //annotation es la chincheta del mapa
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: self.transmittedLatitude, longitude: self.transmittedLongitude)
            annotation.coordinate = coordinate
            annotation.title = self.transmittedTitle
            annotation.subtitle = self.transmittedSubtitle
            self.mapView.addAnnotation(annotation)
            
            self.nameText.text = self.transmittedTitle
            self.commentText.text = self.transmittedSubtitle
            self.distanceToPlace.text = self.transmittedDistance
            //Cambio tambien el nombre del boton por si quiere borrar el contenido.
            self.saveDeleteButton.setTitle("Delete", for: .normal)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Localizacion inicial
        let location = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //seems that he creates an array as attribute
        let saveLocations = locations[0]
        
        let location = CLLocationCoordinate2DMake(saveLocations.coordinate.latitude, saveLocations.coordinate.longitude)
        //Zoom level
        /*let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)*/
        
        
        print("Coordenadas myLocation: ", "Latitud: ",location.latitude, " Longitud: " ,location.longitude)
        print("Coordenadas myLocation: ", "Latitud: ",transmittedLatitude, " Longitud: " ,transmittedLongitude)
        let requestedLocation = CLLocationCoordinate2DMake(transmittedLatitude, transmittedLongitude)
        let point1:MKMapPoint = MKMapPointForCoordinate(location)
        let point2:MKMapPoint = MKMapPointForCoordinate(requestedLocation)
        distanceInMeters = MKMetersBetweenMapPoints(point1, point2)
        print(distanceInMeters)
        print("buttonClicked: ", buttonClicked)
        print("vibrationOn: ", vibrationOn)
        
        
        /*if (vibrationOn){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }*/
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background, target: nil)
        backgroundQueue.async {
            print("Dispatched to background queue")
            while(self.vibrationOn){
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                sleep(1)
                print("vibrando")
                if(!self.vibrationOn){
                    print("salió")
                    break;
                }
            }
        }
        
        if(buttonClicked){
            if(distanceInMeters <= Double(distanceToPlace.text!)!){
                //El problema es que soy incapaz de que salga el alertView y que siga vibrando a parte
                
                let alert = UIAlertController(title: "Alert", message: "Llegando al destino!!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "ArriveApp!!", style: UIAlertActionStyle.default, handler:{action in self.vibrationOn = false}))
                self.present(alert, animated: true, completion: nil)
                
                /*while (!vibrationOn){
                    print("Estoy dentro del while")
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
                print("He salido del while")
                let alert = UIAlertController(title: "Alert", message: "Llegando al destino!!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "ArriveApp!!", style: UIAlertActionStyle.default, handler: { action in }))
                self.present(alert, animated: true, completion: nil)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)*/
                vibrationOn = true
                buttonClicked = false
                
            }
        }
        
        
    }
    
    func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began{
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let chosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            //Lo que hace es establecer valores a las coordenadas que acaba de crear.
            self.chosenLatitude = chosenCoordinates.latitude
            self.chosenLongitude = chosenCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation){
            return nil
        }
        
        let reuseId = "myAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if(transmittedLatitude != 0){
            if(transmittedLongitude != 0){
                self.requestCLLocation = CLLocation(latitude: transmittedLatitude, longitude: transmittedLongitude)
            }
        }
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemark = placemarks {
                if placemark.count > 0 {
                    let newPlaceMark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlaceMark)
                    item.name = self.transmittedTitle
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    
                    item.openInMaps(launchOptions: launchOptions)
                    
                    
                }
            }
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        //let us save our information into coredatamodel
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Hacemos una diferenciacion para borrar o guardar objetos. En caso de que el botón ponga delete borramos de la base de datos despuesde de responder a un alertview. Si pone guardar, se guarda.
        if(self.saveDeleteButton.title(for: .normal)=="Delete"){
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            
            //Esta a false porque es mas eficiente en cuanto a memoria.
            request.returnsObjectsAsFaults = false
            
            do{
                
                
                //Coge todos los datos de la memoria, con el metodo fetch.
                let results = try context.fetch(request)
                
                //Los mete en la tabla, si tengo resultados de la obtencion de datos entoces...
                
                if(results.count > 0){
                    
                    //Vacia todo, incluyendo la capacidad
                    
                    for result in results as! [NSManagedObject]{
                        if result.value(forKey: "title") as? String == nameText.text {
                            context.delete(result)
                            break
                        }
                        
                        

                    }
                }
                
                do {
                    try context.save()
                    print("we managed to save it")
                } catch {
                    print("error")
                }
                
            } catch {
                print("error")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("newLocationDeleted"), object: nil)
            _ = self.navigationController?.popViewController(animated: true)

        } else {
            
            if((self.nameText.text?.isEmpty)!&&(self.distanceToPlace.text?.isEmpty)!){
                let alertEmptyFields = UIAlertController(title: "Nombre y distancia vacíos", message: "Para poder guardar un destino es necesario asignarle un nombre y una distancia.", preferredStyle: UIAlertControllerStyle.alert)
                alertEmptyFields.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.default, handler:nil))
                self.present(alertEmptyFields, animated: true, completion: nil)
            }else if((self.nameText.text?.isEmpty)!){
                let alertEmptyName = UIAlertController(title: "Nombre de destino vacío", message: "Para poder guardar un destino es necesario asignarle un nombre.", preferredStyle: UIAlertControllerStyle.alert)
                alertEmptyName.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.default, handler:nil))
                self.present(alertEmptyName, animated: true, completion: nil)
            } else if((self.distanceToPlace.text?.isEmpty)!){
                let alertEmptyDistance = UIAlertController(title: "Distancia vacía", message: "Para poder guardar un destino es necesario asignarle una distancia de proximidad.", preferredStyle: UIAlertControllerStyle.alert)
                alertEmptyDistance.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.default, handler:nil))
                self.present(alertEmptyDistance, animated: true, completion: nil)
            } else if(Int(self.distanceToPlace.text!) == nil){
                let alertIncorrectDistance = UIAlertController(title: "Distancia incorrecta", message: "La distancia asignada al lugar debe ser un número.", preferredStyle: UIAlertControllerStyle.alert)
                alertIncorrectDistance.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.default, handler:nil))
                self.present(alertIncorrectDistance, animated: true, completion: nil)
            } else {
                
                let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
                
                newLocation.setValue(nameText.text, forKey: "title")
                newLocation.setValue(commentText.text, forKey: "subtitle")
                newLocation.setValue(self.chosenLatitude, forKey: "latitude")
                newLocation.setValue(self.chosenLongitude, forKey: "longitude")
                //En caso de que se guarde sin valor en el textField de comentario, se pone un "" como valor.
                if(commentText.text == ""){
                    commentText.text = ""
                }
                newLocation.setValue(distanceToPlace.text, forKey: "distance")
                
                do {
                    try context.save()
                    print("we managed to save it")
                } catch {
                    print("error")
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newLocationCreated"), object: nil)
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        
    }
    
    
    @IBAction func arrivingButtonClicked(_ sender: Any) {
        //Tengo que añadir aqui el codigo que compruebe que estoy dentro de la zona del objeto guardado o no.
        buttonClicked = true
    }
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

