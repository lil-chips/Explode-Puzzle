import SwiftUI
import PhotosUI
import UIKit

struct AvatarStorage {
    static let customAvatarEnabledKey = "neonpuzzles.customAvatarEnabled"
    static let customAvatarVersionKey = "neonpuzzles.customAvatarVersion"
    static let customAvatarFileName = "custom-avatar.jpg"

    static var avatarURL: URL? {
        let fm = FileManager.default
        guard let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = base.appendingPathComponent("NeonPuzzles", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(customAvatarFileName)
    }

    static func saveCustomAvatar(image: UIImage) throws {
        guard let data = image.jpegData(compressionQuality: 0.88), let url = avatarURL else {
            throw NSError(domain: "AvatarStorage", code: 1)
        }
        try data.write(to: url, options: .atomic)
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: customAvatarEnabledKey)
        defaults.set(defaults.integer(forKey: customAvatarVersionKey) + 1, forKey: customAvatarVersionKey)
    }

    static func removeCustomAvatar() {
        if let url = avatarURL {
            try? FileManager.default.removeItem(at: url)
        }
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: customAvatarEnabledKey)
        defaults.set(defaults.integer(forKey: customAvatarVersionKey) + 1, forKey: customAvatarVersionKey)
    }

    static func loadCustomAvatar() -> UIImage? {
        guard UserDefaults.standard.bool(forKey: customAvatarEnabledKey),
              let url = avatarURL,
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}

struct AvatarBadgeView: View {
    let avatar: PlayerAvatar
    let size: CGFloat
    let showEditBadge: Bool

    @AppStorage(AvatarStorage.customAvatarEnabledKey) private var customAvatarEnabled: Bool = false
    @AppStorage(AvatarStorage.customAvatarVersionKey) private var customAvatarVersion: Int = 0

    private var image: UIImage? {
        _ = customAvatarVersion
        return AvatarStorage.loadCustomAvatar()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(avatar.accent.opacity(0.20))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(avatar.accent.opacity(0.60), lineWidth: 2)
                )

            if customAvatarEnabled, let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 6, height: size - 6)
                    .clipShape(Circle())
            } else {
                Text(avatar.emoji)
                    .font(.system(size: size * 0.46))
                    .frame(width: size, height: size)
            }

            if showEditBadge {
                Circle()
                    .fill(Theme.Neon.surfaceHighest)
                    .frame(width: max(16, size * 0.34), height: max(16, size * 0.34))
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: max(8, size * 0.16), weight: .bold))
                            .foregroundStyle(avatar.accent)
                    )
                    .offset(x: size * 0.34, y: size * 0.34)
            }
        }
        .frame(width: size, height: size)
    }
}

struct AvatarSquareView: View {
    let avatar: PlayerAvatar
    let size: CGFloat

    @AppStorage(AvatarStorage.customAvatarEnabledKey) private var customAvatarEnabled: Bool = false
    @AppStorage(AvatarStorage.customAvatarVersionKey) private var customAvatarVersion: Int = 0

    private var image: UIImage? {
        _ = customAvatarVersion
        return AvatarStorage.loadCustomAvatar()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.14, style: .continuous)
                .fill(avatar.accent.opacity(0.20))
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.14, style: .continuous)
                        .stroke(avatar.accent.opacity(0.35), lineWidth: 1.5)
                )

            if customAvatarEnabled, let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 6, height: size - 6)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.12, style: .continuous))
            } else {
                Text(avatar.emoji)
                    .font(.system(size: size * 0.52))
                    .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
    }
}

struct AvatarPickerSheetView: View {
    @Binding var isPresented: Bool
    @Binding var localAvatarRaw: String

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var importError: String?
    @AppStorage(AvatarStorage.customAvatarEnabledKey) private var customAvatarEnabled: Bool = false
    @AppStorage(AvatarStorage.customAvatarVersionKey) private var customAvatarVersion: Int = 0

    private var currentAvatar: PlayerAvatar {
        PlayerAvatar(rawValue: localAvatarRaw) ?? .cat
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NeonBackgroundView()
                VStack(spacing: 28) {
                    Text("Choose Your Avatar")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                        .padding(.top, 24)

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack(spacing: 12) {
                            AvatarBadgeView(avatar: currentAvatar, size: 52, showEditBadge: false)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(customAvatarEnabled ? "CHANGE PHOTO AVATAR" : "UPLOAD PHOTO AVATAR")
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Theme.Neon.cyan)
                                Text("Pick an image from this device")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.Neon.textMuted)
                            }
                            Spacer()
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.Neon.cyan)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Theme.Neon.surfaceHighest)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Theme.Neon.cyan.opacity(0.35), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)

                    if customAvatarEnabled {
                        Button {
                            AvatarStorage.removeCustomAvatar()
                            customAvatarVersion += 1
                        } label: {
                            Text("REMOVE CUSTOM PHOTO")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.Neon.pink)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(Theme.Neon.pink.opacity(0.14))
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Theme.Neon.pink.opacity(0.32), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    if let importError {
                        Text(importError)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.Neon.pink)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 3), spacing: 18) {
                        ForEach(PlayerAvatar.allCases, id: \.rawValue) { av in
                            Button {
                                localAvatarRaw = av.rawValue
                                isPresented = false
                            } label: {
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(av.accent.opacity(0.20))
                                            .frame(width: 68, height: 68)
                                            .overlay(
                                                Circle()
                                                    .stroke(av.accent.opacity(av.rawValue == localAvatarRaw ? 1.0 : 0.35),
                                                            lineWidth: av.rawValue == localAvatarRaw ? 3 : 1.5)
                                            )
                                        Text(av.emoji)
                                            .font(.system(size: 32))
                                        if av.rawValue == localAvatarRaw && !customAvatarEnabled {
                                            Circle()
                                                .fill(av.accent)
                                                .frame(width: 18, height: 18)
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 9, weight: .heavy))
                                                        .foregroundStyle(.black)
                                                )
                                                .offset(x: 24, y: -24)
                                        }
                                    }
                                    Text(av.label)
                                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                                        .tracking(1.5)
                                        .foregroundStyle(av.rawValue == localAvatarRaw && !customAvatarEnabled ? av.accent : Theme.Neon.textMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(av.rawValue == localAvatarRaw && !customAvatarEnabled ? av.accent.opacity(0.12) : Theme.Neon.surfaceHighest)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(av.rawValue == localAvatarRaw && !customAvatarEnabled ? av.accent.opacity(0.45) : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: localAvatarRaw)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationTitle("AVATAR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isPresented = false }
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.cyan)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                await importPhoto(from: newItem)
            }
        }
    }

    @MainActor
    private func importPhoto(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                importError = "Could not load that image."
                return
            }
            let prepared = image.squareAvatarImage(targetSize: 512)
            try AvatarStorage.saveCustomAvatar(image: prepared)
            customAvatarVersion += 1
            importError = nil
            isPresented = false
        } catch {
            importError = "Failed to save photo avatar."
        }
    }
}

private extension UIImage {
    func squareAvatarImage(targetSize: CGFloat) -> UIImage {
        let originalSize = size
        let side = min(originalSize.width, originalSize.height)
        let cropRect = CGRect(
            x: (originalSize.width - side) / 2,
            y: (originalSize.height - side) / 2,
            width: side,
            height: side
        )

        guard let cgImage = cgImage?.cropping(to: cropRect) else { return self }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetSize, height: targetSize))
        return renderer.image { _ in
            UIImage(cgImage: cgImage).draw(in: CGRect(x: 0, y: 0, width: targetSize, height: targetSize))
        }
    }
}
