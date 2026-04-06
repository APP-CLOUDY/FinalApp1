import UIKit
import PhotosUI

final class TaskSubmissionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let task: ScheduleTaskModelChild
    private let titleLabel = UILabel()
    private let photoLibraryButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var selectedImage: UIImage?

    init(task: ScheduleTaskModelChild) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        titleLabel.text = "Submit: \(task.title)"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        photoLibraryButton.setTitle("Choose from Library", for: .normal)
        photoLibraryButton.backgroundColor = .systemBlue
        photoLibraryButton.setTitleColor(.white, for: .normal)
        photoLibraryButton.layer.cornerRadius = 8
        photoLibraryButton.translatesAutoresizingMaskIntoConstraints = false
        photoLibraryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        view.addSubview(photoLibraryButton)

        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .systemGreen
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        view.addSubview(submitButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            photoLibraryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            photoLibraryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoLibraryButton.widthAnchor.constraint(equalToConstant: 200),
            photoLibraryButton.heightAnchor.constraint(equalToConstant: 50),
            
            submitButton.topAnchor.constraint(equalTo: photoLibraryButton.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 200),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            submitButton.isEnabled = true
            submitButton.alpha = 1.0
            photoLibraryButton.setTitle("Photo Selected ✅", for: .normal)
        }
    }

    @objc private func submitTapped() {
        guard let image = selectedImage else { return }
        activityIndicator.startAnimating()
        submitButton.isEnabled = false
        
        Task {
            do {
                guard let childId = SessionManager.shared.childId else {
                    throw NSError(
                        domain: "TaskSubmission",
                        code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "No child session found for task submission."]
                    )
                }
                
                // 1. Upload the image
                let imageUrl = try await ChildHomeService.shared.uploadProof(image: image, childId: childId)
                
                // 2. ✅ CHECK APPROVAL REQUIREMENT
                // We pull this from the task model (ScheduleTaskModelChild)
                let isApprovalNeeded = task.approval_required ?? false
                
                // 3. ✅ SUBMIT WITH NEW PARAMETER
                try await ChildHomeService.shared.submitTask(
                    taskId: task.id,
                    photoUrl: imageUrl,
                    approvalRequired: isApprovalNeeded // 👈 Passing the logic here
                )
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    NotificationCenter.default.post(name: .taskDidComplete, object: nil)
                    self.dismiss(animated: true)
                }
            } catch {
                print("Error: \(error)")
                let expectedStatus = (task.approval_required ?? false) ? "pending" : "approved"
                let didPersist = await ChildHomeService.shared.verifySubmissionState(
                    taskId: task.id,
                    expectedStatus: expectedStatus,
                    maxAttempts: 8,
                    delayNanoseconds: 500_000_000,
                    submittedAfter: nil
                )

                if didPersist {
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        NotificationCenter.default.post(name: .taskDidComplete, object: nil)
                        self.dismiss(animated: true)
                    }
                    return
                }

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.submitButton.isEnabled = true
                    let alert = UIAlertController(
                        title: "Submission Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
