//
//  MyPageViewController.swift
//  BookSearch
//
//  Created by 김시종 on 4/30/24.
//

import UIKit
import SnapKit
import CoreData

class MyPageViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?
    
    var bookList: [BookCoreData] = []
    
    let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    
    let leftButton: UIButton = {
       let button = UIButton()
        button.setTitle("전체 삭제", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        return button
    }()
    
    let centerLabel: UILabel = {
        let label = UILabel()
        label.text = "마이 페이지"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let viewLine = UIView()
    
    let tabelViewLabel: UILabel = {
        let label = UILabel()
        label.text = "담아 둔 책"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let mypageTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = .white
    }
    
    // MARK: - 마이페이지 내 코어데이터 업데이트
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookList = CoreDataManager.shared.getBookListFromCoreData()
        mypageTableView.reloadData()
    }
    
    // MARK: - SetupUI
    func setupUI() {
        view.addSubview(topStackView)
        view.addSubview(viewLine)
        view.addSubview(tabelViewLabel)
        view.addSubview(mypageTableView)
        topStackView.addArrangedSubview(leftButton)
        topStackView.addArrangedSubview(centerLabel)
        topStackView.addArrangedSubview(rightButton)
        
        let mypageVC = MyPageViewController()
        mypageVC.delegate = self
        
        mypageTableView.dataSource = self
        mypageTableView.delegate = self
        mypageTableView.backgroundColor = .white
        mypageTableView.register(MypageTableViewCell.self, forCellReuseIdentifier: MypageTableViewCell.identifier)
        
        leftButton.addTarget(self, action: #selector(deleteAllBooks), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        viewLine.backgroundColor = .black
        
        topStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(50)
        }
        
        viewLine.snp.makeConstraints {
            $0.top.equalTo(topStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        tabelViewLabel.snp.makeConstraints {
            $0.top.equalTo(viewLine.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        mypageTableView.snp.makeConstraints {
            $0.top.equalTo(tabelViewLabel.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    // MARK: - 검색 탭으로 이동 메서드 구현
    @objc func searchButtonTapped() {
        searchButtonPressed()
    }
    
    // MARK: - 모든 저장한 책 삭제 메서드 구현
    @objc func deleteAllBooks() {
        let alertController = UIAlertController(title: "삭제 확인", message: "담은 책을 모두 삭제 하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            CoreDataManager.shared.deleteAllBooks {
                self.bookList.removeAll()
                self.mypageTableView.reloadData()
            }
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}


extension MyPageViewController: UITableViewDelegate, UITableViewDataSource, SearchViewControllerDelegate {
    
    // MARK: - 추가 버튼 시 검색 탭 이동
    func searchButtonPressed() {
        let searchView = SearchViewController()
        guard let tabBarController = self.tabBarController else { return }
        
        tabBarController.selectedIndex = 0
        delegate?.searchButtonPressed()
    }
    
    // MARK: - TableView Setting
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MypageTableViewCell.identifier, for: indexPath) as? MypageTableViewCell else { fatalError("테이블 뷰 에러") }
        
        let book = bookList[indexPath.row]
        
        cell.mainTitle.text = book.title
        cell.subTitle.text = book.authors
        cell.priceTitle.text = formattedPrice(Int(book.price))
        cell.selectionStyle = .none
                
        return cell
    }
    
    // MARK: - Cell 개별 삭제 기능 구현
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookToDelete = bookList[indexPath.row]
            
            CoreDataManager.shared.deleteBookList(bookToDelete) {
                self.bookList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func formattedPrice(_ price: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedPrice = numberFormatter.string(from: NSNumber(value: price)) ?? ""
        return "\(formattedPrice)원"
    }
}
