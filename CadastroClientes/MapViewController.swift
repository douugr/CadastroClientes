//
//  MapViewController.swift
//  CadastroClientes
//
//  Created by user on 17/08/2018.
//  Copyright © 2018 Doug. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import Alamofire
import CoreLocation

class MapViewController: UIViewController {
    

    @IBOutlet weak var mapKit: MKMapView!
    
    var latitude:NSNumber = NSNumber()
    var longitude:NSNumber = NSNumber()
    var cep = ""
    var number = ""
    var endereco = ""
    var bairro = ""
    var cidade = ""
    var estado = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iniciaPesquisa()
    }
    

    func iniciaPesquisa(){
        let enderecoRaw = "\(self.endereco) \(self.number) \(self.bairro) \(self.cidade) \(self.cep)"
        let removeEspacos = enderecoRaw.replacingOccurrences(of: " ", with: "%20")
        let enderecoWeb = removeEspacos.folding(options: .diacriticInsensitive, locale: .current)
        print(enderecoWeb)
        pesquisaEnd(enderecoQuery: enderecoWeb)
    }
    
    //MARK: Função para buscar no mapa usando a Latitude e Longitude encontrados
    func pesquisaMapa (lat:NSNumber, lng:NSNumber) {

        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: lat), longitude: CLLocationDegrees(truncating: lng))
        
        print(location)
        
        let span = MKCoordinateSpanMake(0.002, 0.002)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapKit.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "\(self.endereco), \(self.number)"
        annotation.subtitle = "\(self.bairro), \(self.cidade) - \(self.endereco) \(self.cep)"
        mapKit.addAnnotation(annotation)

    }
    //MARK: Função para consulta de Lat. e Long. usando API
    func pesquisaEnd(enderecoQuery:String){
    
        Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json?address=\(enderecoQuery)&key=AIzaSyDyBY6_HvQdSUm5yZUSRC701ZjiVCL2TkI").responseJSON { response in
            
            print(response)
            
           
            if let results = response.result.value as! NSDictionary? {
                if let result = results["results"] as! NSObject? {
                    if let geometry = result.value(forKey: "geometry") as! NSObject?{
                        if let location = geometry.value(forKey: "location") as! NSObject? {
                            let latitudeValue = location.value(forKey: "lat") as! NSArray?
                            let longitudeValue = location.value(forKey: "lng") as! NSArray?
                            
                            self.latitude = latitudeValue![0] as! NSNumber
                            self.longitude = longitudeValue![0] as! NSNumber
                            print(latitudeValue![0])
                            print(longitudeValue![0])
                            
                            self.pesquisaMapa(lat: self.latitude, lng: self.longitude)
                        }
                    }
                }
            }
        }
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

}
