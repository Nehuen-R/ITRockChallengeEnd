import UIKit
import AVFoundation
import Combine

class QRScannerView: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    var viewModel = QRScannerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        viewModel.$errorMessage.sink { [weak self] errorMessage in
            guard let self = self else { return }
            if let error = errorMessage {
                self.showAlert(message: error)
            }
        }.store(in: &subscriptions)

        checkCameraPermissionAndStart()
    }

    var subscriptions = Set<AnyCancellable>()

    func checkCameraPermissionAndStart() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            startScanning()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.startScanning()
                    } else {
                        self.showCameraAccessDeniedAlert()
                    }
                }
            }

        case .denied, .restricted:
            showCameraAccessDeniedAlert()

        @unknown default:
            break
        }
    }

    func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Acceso a la cámara denegado",
            message: "Para escanear códigos QR, habilitá el acceso a la cámara desde Configuración.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Ir a Configuración", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }

    func failed() {
        let alert = UIAlertController(title: "Error", message: "Tu dispositivo no soporta escaneo de QR.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        captureSession = nil
    }

    func startScanning() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            failed()
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard viewModel.isScanningActive else { return }
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            captureSession.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            viewModel.handleScannedQR(stringValue)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error QR", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reintentar", style: .default) { _ in
            self.viewModel.resetScanner()
            if !self.captureSession.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession.startRunning()
                }
            }
        })
        present(alert, animated: true)
    }
}
