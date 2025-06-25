//
//  ViewController.swift
//  TestingCoreData
//
//  Created by Creative Frenzy on 23/06/25.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // MARK: - Outlets
       let nameField = UITextField()
       let ageField = UITextField()
       let saveButton = UIButton(type: .system)
       let tableView = UITableView()
       var people: [Person] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("View Controller Called.")
       
        setupUI()
        fetchPeople()
        
    }

    // MARK: - UI Setup
      func setupUI() {
          view.backgroundColor = .white

          nameField.placeholder = "Enter name"
          nameField.borderStyle = .roundedRect
          nameField.translatesAutoresizingMaskIntoConstraints = false

          ageField.placeholder = "Enter age"
          ageField.borderStyle = .roundedRect
          ageField.keyboardType = .numberPad
          ageField.translatesAutoresizingMaskIntoConstraints = false

          saveButton.setTitle("Save", for: .normal)
          saveButton.addTarget(self, action: #selector(savePerson), for: .touchUpInside)
          saveButton.translatesAutoresizingMaskIntoConstraints = false

          tableView.dataSource = self
          tableView.delegate = self
          tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
          tableView.translatesAutoresizingMaskIntoConstraints = false

          view.addSubview(nameField)
          view.addSubview(ageField)
          view.addSubview(saveButton)
          view.addSubview(tableView)

          NSLayoutConstraint.activate([
              nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
              nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
              nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

              ageField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10),
              ageField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
              ageField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

              saveButton.topAnchor.constraint(equalTo: ageField.bottomAnchor, constant: 10),
              saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

              tableView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
              tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
          ])
      }

      // MARK: - Core Data Context
      var context: NSManagedObjectContext {
          return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      }

      // MARK: - Actions
      @objc func savePerson() {
          guard let name = nameField.text, !name.isEmpty,
                let ageText = ageField.text, let age = Int16(ageText) else {
              return
          }

          let person = Person(context: context)
          person.name = name
          person.age = age

          do {
              try context.save()
              fetchPeople()
              nameField.text = ""
              ageField.text = ""
          } catch {
              print("Failed to save: \(error)")
          }
      }

      func fetchPeople() {
          let request: NSFetchRequest<Person> = Person.fetchRequest()

          do {
              people = try context.fetch(request)
              tableView.reloadData()
          } catch {
              print("Fetch failed: \(error)")
          }
      }

      func deletePerson(at indexPath: IndexPath) {
          let personToDelete = people[indexPath.row]
          context.delete(personToDelete)

          do {
              try context.save()
              fetchPeople()
          } catch {
              print("Failed to delete: \(error)")
          }
      }
  }

  // MARK: - TableView
  extension ViewController: UITableViewDataSource, UITableViewDelegate {

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return people.count
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
          let person = people[indexPath.row]
          cell.textLabel?.text = "\(person.name ?? "Unknown") - Age: \(person.age)"
          return cell
      }

      // Swipe to delete
      func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              deletePerson(at: indexPath)
          }
      }
      
}

