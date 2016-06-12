//
//  GetIPAddress.swift
//  ipcountry
//
//  Created by Oleg Medvedev on 2016-06-11.
//  Copyright © 2016 Oleg Medvedev. All rights reserved.
//

import Foundation

struct stIPAddrs {
    var IP = [String]()
    var localIP = [String]()
    var publicIP = String()
}

func getIFAddrs() -> [String] {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
    if getifaddrs(&ifaddr) == 0 {
        
        // For each interface ...
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr.memory.ifa_next }
            
            let flags = Int32(ptr.memory.ifa_flags)
            var addr = ptr.memory.ifa_addr.memory
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        if let address = String.fromCString(hostname) {
                            addresses.append(address)
                        }
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
    }
    
    return addresses
}


//Return a list of addresses
func parseIPAddrs()->stIPAddrs {
    let IFAddrs = getIFAddrs()
    var result = stIPAddrs()
    
    result.IP = IFAddrs
    
    //        '167772160'  => 184549375,  /*    10.0.0.0 -  10.255.255.255 */
    //        '3232235520' => 3232301055, /* 192.168.0.0 - 192.168.255.255 */
    //        '2130706432' => 2147483647, /*   127.0.0.0 - 127.255.255.255 */
    //        '2851995648' => 2852061183, /* 169.254.0.0 - 169.254.255.255 */
    //        '2886729728' => 2887778303, /*  172.16.0.0 -  172.31.255.255 */
    //        '3758096384' => 4026531839, /*   224.0.0.0 - 239.255.255.255 */
    
    for IPAddrs in IFAddrs {
        if IPAddrs.hasPrefix("10.") || IPAddrs.hasPrefix("192.168") || IPAddrs.hasPrefix("127.") || IPAddrs.hasPrefix("169.254") {
                result.localIP.append(IPAddrs)
        }
        else if IP2Long(IPAddrs) > 2886729728 && IP2Long(IPAddrs) < 2887778303 {
            result.localIP.append(IPAddrs)
        }
        else if IP2Long(IPAddrs) > 3758096384 && IP2Long(IPAddrs) < 4026531839 {
            result.localIP.append(IPAddrs)
        }
        else {
            result.publicIP = IPAddrs
        }
        
    }
    return result
}


//Convert IP to Long Format
func IP2Long(IP: String) -> Int {
    var result = Int()
    let parts = IP.characters.split{$0 == "."}.map(String.init)
    
    result  = 0
    result += Int(parts[0])!*16777216
    result += Int(parts[1])!*65536
    result += Int(parts[2])!*256
    result += Int(parts[3])!*1
    
    return result
}

