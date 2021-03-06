//
//  UsersViewController.swift
//  DiscourseClientSwift
//
//  Created by Jorge on 20/03/2020.
//  Copyright © 2020 Jorge. All rights reserved.
//

import UIKit

final class UsersViewController: UIViewController {

    // MARK: - Properties
    private var directoryItems = [DirectoryItem]()
    private let sizeImage = 80

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupData()
    }
}

// MARK: - Setups
extension UsersViewController {

    private func setupUI() {
        self.navigationItem.title = "Usuarios"

        let nib = UINib(nibName: "UserCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: UserCollectionViewCell.cellId)
        collectionView.dataSource = self
        collectionView.delegate = self

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.sectionInset = UIEdgeInsets(top: 24, left: 26, bottom: 24, right: 26)
        flowLayout.itemSize = CGSize(width: 94, height: 124)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = 27.5
        flowLayout.minimumLineSpacing = 18
    }
}

// MARK: - UICollectionViewDelegate
extension UsersViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return directoryItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: UserCollectionViewCell.cellId,
                            for: indexPath) as? UserCollectionViewCell else { return UICollectionViewCell() }

        let user = directoryItems[indexPath.row].user
        cell.nameLabel.text = user.username
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let sizeImage = self?.sizeImage else { return }

            let avatar = user.avatar.replacingOccurrences(of: "{size}", with: String(sizeImage))
            let pathAvatar = "https://mdiscourse.keepcoding.io\(avatar)"
            guard let urlAvatar = URL(string: pathAvatar) else { return }

            // Aquí se produce realmente el proceso costoso
            let data = try? Data.init(contentsOf: urlAvatar)
            DispatchQueue.main.async {
                if let data = data {
                    let image = UIImage(data: data)
                    cell.imageView?.image = image
                    cell.setNeedsLayout()
                }
            }
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegate
extension UsersViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = directoryItems[indexPath.row].user

        let detailVC = DetailUserViewController()
        detailVC.setUsername(user.username)

        self.navigationController?.pushViewController(detailVC, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - API operations
extension UsersViewController {

    private func setupData() {
        getUsers { [weak self] (result) in
            // Al acceder a self dentro de un closure si no se especifica nada lo
            // hará de modo strong generando una referencia fuerte e impidiendo
            // que ARC realice su trabajo. Con [weak self] evitamos dicho comportamiento
            switch result {
            case .failure(let error as CustomTypeError):
                print(error.descripcion)
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let directoryItems):
                self?.directoryItems = directoryItems
                self?.collectionView.reloadData()
            }
        }
    }

    private func getUsers(completion: @escaping (Result<[DirectoryItem], Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)

        guard let url = URL(string: "https://mdiscourse.keepcoding.io/directory_items.json?period=all&order=topic_count") else { return }

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
                        let directoryItemsResponse = try JSONDecoder().decode(DirectoryItemsResponse.self, from: dataset)
                        DispatchQueue.main.async {
                            completion(.success(directoryItemsResponse.directoryItems))
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

}


