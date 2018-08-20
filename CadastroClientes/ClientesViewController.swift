//
//  ViewController.swift
//  CadastroClientes
//
//  Created by user on 17/08/2018.
//  Copyright © 2018 Doug. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ClientesViewController: UIViewController {
    
    var finalContext:NSManagedObjectContext = NSManagedObjectContext()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nibName = UINib(nibName: "ClienteTableViewCell", bundle: nil)
            tableView.register(nibName, forCellReuseIdentifier: "ClienteCell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var tableData:[Any] = [Any]()
    var res:NSManagedObject = NSManagedObject()

    func coreDataFetch(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cliente")
        let context = appDelegate.persistentContainer.viewContext
        self.finalContext = context
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            tableData = result
            }
        catch
        {
            print("Failed")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editaCliente"
        {
            
            let edita = segue.destination as! EditaClienteViewController
            
            do {
                try finalContext.save()
            } catch {
                print("Save Error")
            }
            
           edita.nome = res.value(forKey: "nome") as! String
           edita.cpf = res.value(forKey: "cpf") as! String
           edita.endereco = res.value(forKey: "endereco") as! String
           edita.estado = res.value(forKey: "estado") as! String
           edita.bairro = res.value(forKey: "bairro") as! String
           edita.cep = res.value(forKey: "cep") as! String
           edita.cidade = res.value(forKey: "cidade") as! String
           edita.numero = res.value(forKey: "numero") as! String
           edita.dataNasc = res.value(forKey: "dataNasc") as! String
           edita.id = res.value(forKey: "id") as! Int
           
            
            
        }
    }

}

extension ClientesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClienteCell") as! ClienteTableViewCell
        self.res = tableData[indexPath.row] as! NSManagedObject
        cell.nomeLabel.text = "\(res.value(forKey: "nome") ?? "")"
        cell.cpfLabel.text = "\(res.value(forKey: "cpf") ?? "")"
        cell.dataNascLabel.text = "\(res.value(forKey: "dataNasc") ?? "")"
        cell.endereçoLabel.text = "\(res.value(forKey: "endereco") ?? ""), \(res.value(forKey: "numero") ?? "") - \(res.value(forKey: "bairro") ?? ""), \(res.value(forKey: "cidade") ?? "") - \(res.value(forKey: "estado") ?? "") CEP: \(res.value(forKey: "cep") ?? "")"
        res.setValue(indexPath.row, forKey: "id")
        
        return cell
    }
}

extension ClientesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coreDataFetch()
        return tableData.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.res = tableData[(tableView.indexPathForSelectedRow?.row)!] as! NSManagedObject
        self.performSegue(withIdentifier: "editaCliente", sender: tableView)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let res = tableData[indexPath.row] as! NSManagedObject
            tableData.remove(at: indexPath.row)
            finalContext.delete(res)
            
            do{
                try finalContext.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Delete Error")
            }
                
        } 
    }
}
