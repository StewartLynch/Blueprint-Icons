//
//----------------------------------------------
// Original project: Blueprint Icons
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.


import Foundation

nonisolated struct ProcessResult: Sendable {
    let status: Int32
    let output: String
    let error: String
    /// True if the process was stopped because it ran past the timeout.
    let timedOut: Bool
    var succeeded: Bool { status == 0 && !timedOut }
}

/// A tiny thread-safe flag used to record that a timeout fired.
private nonisolated final class TimeoutFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false
    func set() { lock.lock(); value = true; lock.unlock() }
    var isSet: Bool { lock.lock(); defer { lock.unlock() }; return value }
}

/// Runs a command line program off the main thread and returns its output.
nonisolated enum ProcessRunner {
    /// Returns nil if the program could not be launched at all.
    /// The process is terminated if it runs longer than `timeout` seconds.
    static func run(_ executable: String, arguments: [String] = [], timeout: TimeInterval = 5) async -> ProcessResult? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: executable)
                process.arguments = arguments
                let outPipe = Pipe()
                let errPipe = Pipe()
                process.standardOutput = outPipe
                process.standardError = errPipe
                process.standardInput = FileHandle.nullDevice
                do {
                    try process.run()
                } catch {
                    continuation.resume(returning: nil)
                    return
                }
                let timeoutFlag = TimeoutFlag()
                DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                    if process.isRunning {
                        timeoutFlag.set()
                        process.terminate()
                    }
                }
                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                continuation.resume(returning: ProcessResult(
                    status: process.terminationStatus,
                    output: String(decoding: outData, as: UTF8.self),
                    error: String(decoding: errData, as: UTF8.self),
                    timedOut: timeoutFlag.isSet
                ))
            }
        }
    }
}
