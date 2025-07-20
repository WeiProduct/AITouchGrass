import SwiftUI
import AVFoundation
import Photos

/// 完全重写的相机视图，确保权限正确处理
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let coordinator = context.coordinator
        
        // 创建权限检查控制器
        let permissionController = UIViewController()
        
        // 立即检查并请求权限
        coordinator.checkAndRequestPermissions { [weak permissionController] granted in
            DispatchQueue.main.async {
                if granted {
                    // 权限获取成功，显示相机
                    let cameraController = coordinator.createCameraController()
                    permissionController?.present(cameraController, animated: true)
                } else {
                    // 权限被拒绝，显示设置提示
                    coordinator.showPermissionAlert(on: permissionController)
                }
            }
        }
        
        return permissionController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func checkAndRequestPermissions(completion: @escaping (Bool) -> Void) {
            print("DEBUG: Checking camera permissions...")
            
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch cameraStatus {
            case .authorized:
                print("DEBUG: Camera already authorized")
                completion(true)
                
            case .notDetermined:
                print("DEBUG: Requesting camera permission")
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    print("DEBUG: Camera permission result: \(granted)")
                    completion(granted)
                }
                
            case .denied, .restricted:
                print("DEBUG: Camera permission denied/restricted")
                completion(false)
                
            @unknown default:
                print("DEBUG: Unknown camera permission status")
                completion(false)
            }
        }
        
        func createCameraController() -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = self
            
            // 根据可用性选择源
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
                print("DEBUG: Using camera")
            } else {
                picker.sourceType = .photoLibrary
                print("DEBUG: Camera not available, using photo library")
            }
            
            picker.allowsEditing = false
            return picker
        }
        
        func showPermissionAlert(on viewController: UIViewController?) {
            let alert = UIAlertController(
                title: "需要相机权限",
                message: "AITouchGrass需要访问相机来拍摄自然景观。请在设置中开启相机权限。",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                self.parent.isPresented = false
            })
            
            alert.addAction(UIAlertAction(title: "使用照片库", style: .default) { _ in
                let libraryPicker = UIImagePickerController()
                libraryPicker.delegate = self
                libraryPicker.sourceType = .photoLibrary
                viewController?.present(libraryPicker, animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                self.parent.isPresented = false
            })
            
            viewController?.present(alert, animated: true)
        }
        
        // MARK: - UIImagePickerControllerDelegate
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("DEBUG: Image picker finished")
            
            // 先关闭picker，再处理图像
            picker.dismiss(animated: true) {
                if let selectedImage = info[.originalImage] as? UIImage {
                    print("DEBUG: Image selected successfully, size: \(selectedImage.size)")
                    self.parent.image = selectedImage
                } else {
                    print("DEBUG: Failed to get image from picker")
                }
                self.parent.isPresented = false
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("DEBUG: Image picker cancelled")
            picker.dismiss(animated: true) {
                self.parent.isPresented = false
            }
        }
    }
}

/// 相机权限管理器
class CameraPermissionManager: ObservableObject {
    @Published var hasPermission = false
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    
    init() {
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        hasPermission = permissionStatus == .authorized
    }
    
    func requestPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.checkPermissionStatus()
                    continuation.resume(returning: granted)
                }
            }
        }
    }
}