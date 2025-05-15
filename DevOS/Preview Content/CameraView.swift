//
//  CameraView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 29/04/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var camera = CameraViewModel()
    @State private var showBottomSheet = false

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Button(action: {
                    camera.capturePhoto()
                }) {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .onChange(of: camera.capturedImage) { oldValue, newValue in
            if newValue != nil {
                showBottomSheet = true
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            if let image = camera.capturedImage {
                    VStack {
                        Text("Foto Capturada")
                            .font(.headline)
                            .padding()

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding()

                        Button("Cerrar") {
                            showBottomSheet = false
                        }
                        .padding(.bottom)
                    }
                    .presentationDetents([.medium, .large])
                }
                   
        }

    }
}

#Preview {
    CameraView()
}



struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

 

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}
