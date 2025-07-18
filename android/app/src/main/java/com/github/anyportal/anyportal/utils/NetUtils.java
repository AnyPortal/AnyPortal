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
import java.net.Inet4Address;
import java.net.Inet6Address;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class NetUtils {
    private static final String TAG = "NetUtils";
    private static Set<Network> networks = new HashSet<>();

    public static void init(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
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

    public static String getActiveLocalIpv4(VpnService vpnService) {
        try {
            DatagramSocket socket = new DatagramSocket();
            vpnService.protect(socket);
            socket.connect(InetAddress.getByName("8.8.8.8"), 53);
            String localIp = socket.getLocalAddress().getHostAddress();
            socket.close();
            return localIp;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String getActiveLocalIpv6(VpnService vpnService) {
        try {
            DatagramSocket socket6 = new DatagramSocket();
            vpnService.protect(socket6);
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

    public static Network findMatchingNetwork(ConnectivityManager cm, String localIp) {
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
            for (LinkAddress addr : props.getLinkAddresses()) {
                if (addr.getAddress().getHostAddress().equals(localIp)) {
                    return network;
                }
            }
        }
        Log.w(TAG, "no matching network");
        return null;
    }

    public static JSONObject getEffectiveLinkProperties(
            ConnectivityManager cm,
            Network network,
            String activeLocalIpv4,
            String activeLocalIpv6) {
        LinkProperties props = cm.getLinkProperties(network);
        if (props == null)
            return null;

        String interfaceName = props.getInterfaceName();
        List<InetAddress> dnsServers = props.getDnsServers();
        List<LinkAddress> linkAddresses = props.getLinkAddresses();

        JSONObject result = new JSONObject();
        try {
            result.put("interfaceName", interfaceName);
            JSONArray dnsList = new JSONArray();
            for (InetAddress dns : dnsServers) {
                dnsList.put(dns.getHostAddress());
            }
            result.put("dnsServers", dnsList);
            JSONArray linkAddressList = new JSONArray();
            for (LinkAddress linkAddress : linkAddresses) {
                linkAddressList.put(linkAddress.getAddress().getHostAddress());
            }
            result.put("linkAddresses", linkAddressList);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return result;
    }
}
