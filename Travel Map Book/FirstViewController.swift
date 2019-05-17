//
//  FirstViewController.swift
//  Travel Map Book
//
//  Created by Eloy on 22/07/2017.
//  Copyright © 2017 ERH. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var subtitleArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var distanceArray = [String]()
    
    var chosenTitle = ""
    var chosenSubtitle = ""
    var chosenLatitude : Double = 0
    var chosenLongitude : Double = 0
    var chosenDistance = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the 
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.topItem?.title = "Lugares guardados"
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.fetchData), name: NSNotification.Name(rawValue: "newLocationCreated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.fetchData), name: NSNotification.Name("newLocationDeleted"), object: nil)
        chosenTitle = ""
        chosenSubtitle = ""
        chosenLatitude = 0
        chosenLongitude = 0
        chosenDistance = ""
    }
    
    func fetchData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        
        //Esta a false porque es mas eficiente en cuanto a memoria.
        request.returnsObjectsAsFaults = false
        
        do{

            
            //Coge todos los datos de la memoria, con el metodo fetch.
            let results = try context.fetch(request)
            
            //Los mete en la tabla, si tengo resultados de la obtencion de datos entoces entonces meto lo que tengo, pero si no tengo (es decir, = a 0) borro todos los elementos de la tabla y la presento.
            
            if(results.count > 0){
                
                //Vacia todo, incluyendo la capacidad
                self.titleArray.removeAll(keepingCapacity: false)
                self.subtitleArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                self.distanceArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let subtitle = result.value(forKey: "subtitle") as? String{
                        self.subtitleArray.append(subtitle)
                    }
                    if let latitude = result.value(forKey: "latitude") as? Double{
                        self.latitudeArray.append(latitude)
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double {
                        self.longitudeArray.append(longitude)
                    }
                    if let distance = result.value(forKey: "distance") as? String {
                        self.distanceArray.append(distance)
                    }
                
                    //Recarga los datos modificados en la tabla
                    self.tableView.reloadData()
                    
                }
            } else {
                self.titleArray.removeAll(keepingCapacity: false)
                self.subtitleArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                self.distanceArray.removeAll(keepingCapacity: false)
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Pone el mismo indice porque estan colocados en el mismo orden
        chosenTitle = titleArray[indexPath.row]
        chosenSubtitle = subtitleArray[indexPath.row]
        chosenLatitude = latitudeArray[indexPath.row]
        chosenLongitude = longitudeArray[indexPath.row]
        chosenDistance = distanceArray[indexPath.row]
        
        performSegue(withIdentifier: "toMapVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMapVC"){
            let destinationVC = segue.destination as! ViewController
            destinationVC.transmittedTitle = chosenTitle
            destinationVC.transmittedSubtitle = chosenSubtitle
            destinationVC.transmittedLatitude = chosenLatitude
            destinationVC.transmittedLongitude = chosenLongitude
            destinationVC.transmittedDistance = chosenDistance
            print("Distancia seleccionada: ", chosenDistance)
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func addButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }

}
