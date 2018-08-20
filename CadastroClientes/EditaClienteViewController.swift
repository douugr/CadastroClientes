//
//  EditaClienteViewController.swift
//  CadastroClientes
//
//  Created by user on 17/08/2018.
//  Copyright © 2018 Doug. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AKMaskField

class EditaClienteViewController: UIViewController, UITextFieldDelegate {
    
    var nome = ""
    var cpf = ""
    var endereco = ""
    var numero = ""
    var cep = ""
    var cidade = ""
    var bairro = ""
    var estado = ""
    var dataNasc = ""
    var id:Int = 0
    var sv:UIView = UIView()
    
    
    @IBOutlet weak var editaNome: UITextField!
    @IBOutlet weak var editaCPF: UITextField!
    @IBOutlet weak var editaEndereço: UITextField!
    @IBOutlet weak var editaNumero: UITextField!
    @IBOutlet weak var editaBairro: UITextField!
    @IBOutlet weak var editaEstado: UITextField!
    @IBOutlet weak var editaDataNasc: UIDatePicker!
    @IBOutlet weak var editaCidade: UITextField!
    @IBOutlet weak var editaCEP: UITextField! {
        didSet{
            editaCEP.addTarget(self, action: #selector(EditaClienteViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            editaCEP.addTarget(self, action: #selector(EditaClienteViewController.textFieldSelected(_:)), for: UIControlEvents.touchDown)
            editaCEP.delegate = self
        }
    }
    
    func commonInit(){
        
        editaNumero.text = numero
        editaCEP.text = cep
        editaEstado.text = estado
        editaEndereço.text = endereco
        editaCPF.text = cpf
        editaCidade.text = cidade
        editaNome.text = nome
        editaBairro.text = bairro
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.date(from: dataNasc)
        editaDataNasc.date = date!
        editaDataNasc.maximumDate = Date()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        commonInit()
    }
    
    @objc func textFieldSelected(_: UITextField){
        editaCEP.text = ""
    }
    
    @objc func textFieldDidChange(_: UITextField) {
        print("changed")
        if editaCEP.text!.count == 5{
            editaCEP.text!.append("-")
        }
        if editaCEP.text!.count == 9 {
            self.sv = UIViewController.displaySpinner(onView: self.view)
            Alamofire.request("https://viacep.com.br/ws/\(editaCEP.text ?? "01001000")/json/").responseJSON { response in
                
                if let responseValue = response.result.value as! [String: Any]? {
                    self.editaEndereço.text = responseValue["logradouro"] as? String
                    self.editaBairro.text = responseValue["bairro"] as? String
                    self.editaEstado.text = responseValue["uf"] as? String
                    self.editaCidade.text = responseValue["localidade"] as? String
                    
                }
            }
            editaCEP.isEnabled = false
        }
        UIViewController.removeSpinner(spinner: sv)
        editaCEP.isEnabled = true
        
    }
    
    

    //MARK: Função para confirmar a edição
    @IBAction func confirmaEdicao(_ sender: Any) {
        
        if(editaNumero.text == "" || editaCEP.text == "" || editaEstado.text == "" || editaEndereço.text == "" || editaCPF.text == "" || editaCidade.text == "" || editaNome.text == "" || editaBairro.text == ""){
            
            alertaNulo()
            return
            
        } else {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dataNasc = formatter.string(from: editaDataNasc.date)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cliente")
        let context = appDelegate.persistentContainer.viewContext
        let predicate = NSPredicate(format: "id == '\(self.id)'")
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count == 1 {
                let objectUpdate = result[0] as! NSManagedObject
                objectUpdate.setValue(self.id, forKeyPath: "id")
                objectUpdate.setValue(editaNumero.text, forKey: "numero")
                objectUpdate.setValue(editaCEP.text, forKey: "cep")
                objectUpdate.setValue(editaCPF.text, forKey: "cpf")
                objectUpdate.setValue(editaNome.text, forKey: "nome")
                objectUpdate.setValue(editaBairro.text, forKey: "bairro")
                objectUpdate.setValue(editaCidade.text, forKey: "cidade")
                objectUpdate.setValue(editaEstado.text, forKey: "estado")
                objectUpdate.setValue(editaEndereço.text, forKey: "endereco")
                objectUpdate.setValue(dataNasc, forKey: "dataNasc")
                do {
                    try context.save()
                } catch {
                    print("error")
                }
            }
        }
        catch
        {
            print("Failed")
        }
        
        self.performSegue(withIdentifier: "confirmaEdicao", sender: self)
        }
    }


    func alertaNulo(){
        let alert = UIAlertController(title: "Erro", message: "Favor Preencher todos os Campos", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verMapa"{
            let map = segue.destination as! MapViewController
            map.cep  = editaCEP.text!
            map.number = editaNumero.text!
            map.bairro = editaBairro.text!
            map.cidade = editaCidade.text!
            map.estado = editaEstado.text!
            map.endereco = editaEndereço.text!
        }
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
