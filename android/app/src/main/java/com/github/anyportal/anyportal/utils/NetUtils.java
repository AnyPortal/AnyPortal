package com.github.anyportal.anyportal.utils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.LinkAddress;
import android.net.LinkProperties;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.net.VpnService;
import android.util.Log;

import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class NetUtils {
    private static final String TAG = "NetUtils";
    private static Set<Network> networks = new HashSet<>();
    private static ConnectivityManager cm;
    private static VpnService _vpnService;

    public static void init(VpnService vpnService) {
        _vpnService = vpnService;
        Context context = vpnService.getApplicationContext();
        cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        networks.add(cm.getActiveNetwork());

        NetworkRequest request = new NetworkRequest.Builder()
                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .build();

        cm.registerNetworkCallback(request, new ConnectivityManager.NetworkCallback() {
            @Override
            public void onAvailable(Network network) {
                NetworkCapabilities caps = cm.getNetworkCapabilities(network);
                if (caps != null && !caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
                    // This network is real working Internet, not the VPN.
                    networks.add(network);
                }
            }

            @Override
            public void onLost(Network network) {
                networks.remove(network);
            }

            @Override
            public void onCapabilitiesChanged(Network network, NetworkCapabilities caps) {
                // Update your info if needed (e.g. validated state changes)
            }

            @Override
            public void onLinkPropertiesChanged(Network network, LinkProperties props) {
                // Update IP, DNS, etc.
            }
        });
    }

    public static String getActiveLocalIpv4() {
        try {
            DatagramSocket socket = new DatagramSocket();
            _vpnService.protect(socket);
            socket.connect(InetAddress.getByName("8.8.8.8"), 53);
            String localIp = socket.getLocalAddress().getHostAddress();
            socket.close();
            return localIp;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String getActiveLocalIpv6() {
        try {
            DatagramSocket socket6 = new DatagramSocket();
            _vpnService.protect(socket6);
            socket6.connect(InetAddress.getByName("2001:4860:4860::8888"), 53);
            String localIp = socket6.getLocalAddress().getHostAddress();
            socket6.close();
            if (localIp.equals("::")) {
                return null;
            }
            return localIp;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static Network findMatchingNetwork(String localIp) {
        // Log.d(TAG, String.format("localIp: %s", localIp));
        if (localIp == null)
            return null;
        // for (Network network : cm.getAllNetworks()) {
        for (Network network : networks) {
            NetworkCapabilities caps = cm.getNetworkCapabilities(network);
            if (caps == null) {
                continue;
            }
            // if (!caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET))
            // continue;
            // if (caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN))
            // continue;

            LinkProperties props = cm.getLinkProperties(network);
            if (props == null) {
                continue;
            }
            // Log.d(TAG, String.format("interfaceName: %s", props.getInterfaceName()));
            for (LinkAddress addr : props.getLinkAddresses()) {
                // Log.d(TAG, String.format("addr: %s", addr));
                if (addr.getAddress().getHostAddress().equals(localIp)) {
                    return network;
                }
            }
        }
        Log.w(TAG, "no matching network");
        return null;
    }

    private static Map<String, Object> _getEffectiveLinkProperties(
            Network network,
            String activeLocalIpv4,
            String activeLocalIpv6) {
        LinkProperties props = cm.getLinkProperties(network);
        if (props == null)
            return null;

        String interfaceName = props.getInterfaceName();
        List<InetAddress> dnsServers = props.getDnsServers();
        List<LinkAddress> linkAddresses = props.getLinkAddresses();

        Map<String, Object> result = new HashMap<>();
        result.put("interfaceName", interfaceName);
        List<String> dnsList = new ArrayList<>();
        for (InetAddress dns : dnsServers) {
            dnsList.add(dns.getHostAddress());
        }
        result.put("dnsServers", dnsList);
        List<String> linkAddressList = new ArrayList<>();
        for (LinkAddress linkAddress : linkAddresses) {
            linkAddressList.add(linkAddress.getAddress().getHostAddress());
        }
        result.put("linkAddresses", linkAddressList);
        return result;
    }

    public static Map<String, Object> getEffectiveLinkProperties() {
        String activeLocalIpv6 = getActiveLocalIpv6();
        String activeLocalIpv4 = getActiveLocalIpv4();
        String activeLocalIp = activeLocalIpv4 != null ? activeLocalIpv4 : activeLocalIpv6;
        Network matching = findMatchingNetwork(activeLocalIp);
        Map<String, Object> info = _getEffectiveLinkProperties(matching, activeLocalIpv4, activeLocalIpv6);
        return info;
    }
}
