//
//  DetailTopicsViewController.swift
//  DiscourseClientSwift
//
//  Created by Jorge on 21/03/2020.
//  Copyright © 2020 Jorge. All rights reserved.
//

import UIKit

final class DetailTopicsViewController: UIViewController {

    // MARK: - Properties
    private var viewModel: TopicViewModel?
    internal var delegate: TopicDelegate?

    // MARK: - IBOutlets
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupData()
    }

    // MARK: - IBActions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let id = viewModel?.getId() else { return }
        deleteTopic(id: id) { [weak self] (result) in
            // Al acceder a self dentro de un closure si no se especifica nada lo
            // hará de modo strong generando una referencia fuerte e impidiendo
            // que ARC realice su trabajo. Con [weak self] evitamos dicho comportamiento
            if result == true {
                self?.delegate?.deleteTopic()
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showAlert(title: "DELETE", message: CustomTypeError.unknowError.descripcion)
            }
        }
    }

}

// MARK: - Setups
extension DetailTopicsViewController {

    private func setupUI() {
        deleteButton.layer.cornerRadius = 4.0
        deleteButton.backgroundColor = UIColor(displayP3Red: 146/255.0, green: 178/255.0, blue: 121/255.0, alpha: 1.0)
        deleteButton.tintColor = .white

        //! Mejorar este código, es feo con ganas
        guard let viewModel = self.viewModel else { return }
        idLabel.text = "Id: \(viewModel.getId())"
        titleTextView.text = "Title: \(viewModel.getTitle())"
        postsCountLabel.text = "Posts count: \(viewModel.getPostCount())"
        deleteButton.isHidden = true
    }

    private func setupData() {
        guard let viewModel = self.viewModel else { return }
        getCanDeleteTopic(id: viewModel.getId()) { [weak self] (resul) in
            // Al acceder a self dentro de un closure si no se especifica nada lo
            // hará de modo strong generando una referencia fuerte e impidiendo
            // que ARC realice su trabajo. Con [weak self] evitamos dicho comportamiento
            switch resul {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let detail):
                guard let canDelete = detail.canDelete else { return }
                self?.deleteButton.isHidden = !canDelete
            }
        }
    }

}

// MARK: - API operations
extension DetailTopicsViewController {

    private func getCanDeleteTopic(id: Int, completion: @escaping (Result<Detail, Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)

        let urlString = "https://mdiscourse.keepcoding.io/t/\(id).json"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(kApiKey, forHTTPHeaderField: "Api-Key")
        request.addValue(kApiUserName, forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
            }
            if let resp = response as? HTTPURLResponse, resp.statusCode == 200 {
                if let dataset = data {
                    do {
                        let singleTopicResponse = try JSONDecoder().decode(SingleTopicResponse.self, from: dataset)
                        DispatchQueue.main.async {
                            completion(.success(singleTopicResponse.details))
                        }
                    } catch let errorDecoding as DecodingError {
                        DispatchQueue.main.async {
                            completion(.failure(errorDecoding))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(CustomTypeError.unknowError))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(CustomTypeError.emptyData))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(CustomTypeError.responseError))
                }
            }
        }
        dataTask.resume()
    }

    private func deleteTopic(id: Int, completion: @escaping (Bool) -> Void) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)

        guard let url = URL(string: "https://mdiscourse.keepcoding.io/t/\(id).json") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(kApiKey, forHTTPHeaderField: "Api-Key")
        request.addValue(kApiUserName, forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let dataTask = session.dataTask(with: request) { (_, response, error) in
            if let _ = error {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            if let resp = response as? HTTPURLResponse, resp.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        dataTask.resume()
    }

}

// MARK: - Public functions
extension DetailTopicsViewController {

    func setTopic(viewModel: TopicViewModel) {
        self.viewModel = viewModel
    }

}









