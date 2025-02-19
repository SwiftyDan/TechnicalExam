//
//  Logger.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import os.log

func infoLog(file: String = #file, function: String = #function, line: Int = #line, _ args: CVarArg...) {
    log(.info, file: file, function: function, line: line, args: args)
}

func errorLog(file: String = #file, function: String = #function, line: Int = #line, _ args: CVarArg...) {
    log(.error, file: file, function: function, line: line, args: args)
}

func debugLog(file: String = #file, function: String = #function, line: Int = #line, _ args: CVarArg...) {
#if DEBUG
    log(.debug, file: file, function: function, line: line, args: args)
#endif
}

func log(_ logLevel: OSLogType, file: String, function: String, line: Int, args: [CVarArg]) {
    let filename = String(file.split(separator: "/").last ?? "")
    let message: String =  args.count < 1 ? "" : String(format: args[0] as! String, arguments: Array(args[1...]))
    os_log(.info, "[%@]:[%@]@%d - %@", filename, function, line, message)
}
