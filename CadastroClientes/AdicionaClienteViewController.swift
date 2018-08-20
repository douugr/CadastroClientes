//
//  AdicionaClienteViewController.swift
//  CadastroClientes
//
//  Created by user on 17/08/2018.
//  Copyright © 2018 Doug. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import AKMaskField


class AdicionaClienteViewController: UIViewController, UITextFieldDelegate {

    //MARK: Variáveis
    var sv:UIView = UIView()
    @IBOutlet weak var nomeTextField: UITextField!
    @IBOutlet weak var cpfTextField: UITextField!
    @IBOutlet weak var enderecoTextField: UITextField!
    @IBOutlet weak var numeroTextField: UITextField!
    @IBOutlet weak var bairroTextField: UITextField!
    @IBOutlet weak var estadoTextField: UITextField!
    @IBOutlet weak var dataNascPicker: UIDatePicker!
    @IBOutlet weak var cidadeTextField: UITextField!
    @IBOutlet weak var cepTextField: UITextField! {
        didSet{
            cepTextField.addTarget(self, action: #selector(AdicionaClienteViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            cepTextField.addTarget(self, action: #selector(AdicionaClienteViewController.textFieldSelected(_:)), for: UIControlEvents.touchDown)
        }
    }
    
    //MARK: Busca o endereço na API dos correios
    @objc func textFieldSelected(_: UITextField) {
        cepTextField!.text = ""
    }
    
    @objc func textFieldDidChange(_: UITextField) {
        print("changed")
        if cepTextField.text!.count == 5{
            cepTextField.text!.append("-")
        }
        if cepTextField.text!.count == 9 {
        self.sv = UIViewController.displaySpinner(onView: self.view)
        Alamofire.request("https://viacep.com.br/ws/\(cepTextField.text ?? "01001000")/json/").responseJSON { response in
            
            if let responseValue = response.result.value as! [String: Any]? {
                self.enderecoTextField.text = responseValue["logradouro"] as? String
                self.bairroTextField.text = responseValue["bairro"] as? String
                self.estadoTextField.text = responseValue["uf"] as? String
                self.cidadeTextField.text = responseValue["localidade"] as? String
                
            }
        }
            cepTextField.isEnabled = false
      }
        UIViewController.removeSpinner(spinner: sv)
        cepTextField.isEnabled = true
    }
    
    func customInit(){
        
        dataNascPicker.maximumDate = Date()
    }
    
    @IBAction func adicionaCliente(_ sender: Any) {
        if(nomeTextField.text == "" || cpfTextField.text == "" || enderecoTextField.text == "" || numeroTextField.text == "" || cepTextField.text == "" || bairroTextField.text == "" || estadoTextField.text == "" || cidadeTextField.text == "") {
            alertaNulo()
            return
        } else {
        performSegue(withIdentifier: "adicionaCliente", sender: Any?.self)
        }
    }
    //MARK: Função para chamar o Alerta
    func alertaNulo(){
        let alert = UIAlertController(title: "Erro", message: "Favor Preencher todos os Campos", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Salva o cliente no Core Data
    func salvaCliente() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Cliente", in: context)
        let newCliente = NSManagedObject(entity: entity!, insertInto: context)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let dataNasc = formatter.string(from: dataNascPicker.date)
        
        newCliente.setValue(nomeTextField.text, forKey: "nome")
        newCliente.setValue(cpfTextField.text, forKey: "cpf")
        newCliente.setValue(dataNasc, forKey: "dataNasc")
        newCliente.setValue(enderecoTextField.text, forKey:"endereco")
        newCliente.setValue(numeroTextField.text, forKey: "numero")
        newCliente.setValue(cidadeTextField.text, forKey: "cidade")
        newCliente.setValue(cepTextField.text, forKey: "cep")
        newCliente.setValue(estadoTextField.text, forKey: "estado")
        newCliente.setValue(bairroTextField.text, forKey: "bairro")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        escondeKeyboard()
        customInit()
    }
    
    //MARK: Funções para esconder o teclado
    func escondeKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Segue para voltar para a tabela de clientes
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        salvaCliente()
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
