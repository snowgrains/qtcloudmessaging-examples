package com.snowgrains.radarsensor;

import android.os.Messenger;
import android.os.Message;
import android.os.Handler;
import android.os.IBinder;
import android.os.RemoteException;
import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.ComponentName;
import android.util.Log;

public class KaltiotWrapper {

    /* Payload types for notification callback and MSG_SEND_PAYLOAD
     * make sure to keep these in sync with KaltiotSmartGatewayApi
     */
    public static final int PAYLOAD_BINARY = 1;
    public static final int PAYLOAD_INT = 2;
    public static final int PAYLOAD_STRING = 3;
    public static final int PAYLOAD_PING = 4;
    public static final int PAYLOAD_PONG = 5;

    /**
     * Command to the service to register a client, receiving callbacks
     * from the service.  Message.replyTo must be a Messenger of
     * the client where callbacks should be sent.
     * Message.getData().getString("address") stores the client's address.
     */
    public static final int MSG_REGISTER_CLIENT = 11;

    /**
     * Command to the service to unregister a client, ot stop receiving callbacks
     * from the service.  Message.replyTo must be a Messenger of
     * the client as previously given with MSG_REGISTER_CLIENT.
     * Message.getData().getString("address") stores the client's address.
     */
    public static final int MSG_UNREGISTER_CLIENT = 12;

    /**
     * Command for sending state.  Message.arg1 is the state.
     * Message.getData().getString("address") stores the client's address.
     */
    public static final int MSG_SET_STATE = 13;

    /**
     * Command for sending a notification (from server) or publish (to server).
     * Message.arg1 is the payload type.
     * Message.getData().getString("data") stores the payload as String.
     */
    public static final int MSG_SEND_PAYLOAD = 14;

    /**
     * Command for client.
     * Message.getData().getString("data") stores the client's unique RID.
     */
    public static final int MSG_SET_RID = 15;

    /**
     * Command for client, informing whether the network connection is available.
     * Message.arg1 is the network status, 0=unavailable, 1=available.
     */
    public static final int MSG_SET_NETWORK_AVAILABLE = 16;

    /**
     * Command for sending GSP enable/disable.
     * Message.arg1 is the GPS value, 0=disabled, 1=enabled.
     * Message.getData().getString("address") stores the client's address.
     */
    public static final int MSG_SET_GPS = 17;

    /**
     * Command for sending strings.
     * Message.getData().getString("data") stores the string.
     * Message.getData().getString("lat") stores the string.
     * Message.getData().getString("lon") stores the string.
     * Message.getData().getString("address") stores the client's address.
     */
    public static final int MSG_SET_VALUE = 18;

    /**
     * Command for client.
     * Message.getData().getString("data") stores the service application ID.
     */
    public static final int MSG_SET_APPID = 19;


    String addr = null;
    String id = null;
    QtApp appCb = null;
    Context context = null;

    /** Messenger for communicating with service. */
    Messenger mService = null;
    /** Flag indicating whether we have called bind on the service. */
    boolean mIsBound = false;

    public KaltiotWrapper(String address, String customer_id, QtApp cb, Context ctx) {
        addr = address;
        id = customer_id;
        appCb = cb;
        context = ctx;
    }

    // Send a publish Message to the service
    public void publishMessage(String payload, int payload_type) {

        if (mService != null) try {
            Message msg = Message.obtain(null, MSG_SEND_PAYLOAD);
            Bundle b = new Bundle();
            b.putString("data", payload);
            msg.arg1 = payload_type;
            msg.replyTo = mMessenger;
            msg.setData(b);
            mService.send(msg);
        } catch (RemoteException e) {
            // There is nothing special we need to do if the service
            // has crashed.
        }
    }
    public void requestRID() {
        if (mService != null) try {
            Message msg = Message.obtain(null, MSG_SET_RID);
            Bundle b = new Bundle();

            b.putString("address", addr);

            msg.setData(b);
            mService.send(msg);
        } catch (RemoteException e) {
            // There is nothing special we need to do if the service
            // has crashed.
        }
    }


    /**
     * Handler of incoming messages from SensorService.
     */
    class ClientIncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            String address = msg.getData().getString("address");

            switch (msg.what) {
                case MSG_SET_STATE:
                    String state = msg.getData().getString("data");

                    appCb.state_callback(address,state);
                    break;
                case MSG_SEND_PAYLOAD:
                    String str = msg.getData().getString("data");
                    str = str.substring(0, str.length()-1);
                    String msgid = msg.getData().getString("id");
                    //Log.i(addr, "Received: "+msg.arg1+": "+str);
                    appCb.notification_callback(address, str,
                                  (str != null) ? str.length() : 0, msg.arg1, msgid);
                    break;
                case MSG_SET_VALUE:
                    String val = msg.getData().getString("data");
                    //Log.i(addr, "Value: "+val);

                    appCb.value_callback(address,val);
                    break;
                case MSG_SET_RID:
                    String rid = msg.getData().getString("data");

                    //Log.i(addr, "RID: "+rid);
                    appCb.rid_callback(address,rid);
                    break;
                case MSG_SET_APPID:

                    String appid = msg.getData().getString("data");
                    //Log.i(addr, "AppID: "+appid);
                    appCb.appid_callback(address,appid);
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    /**
     * Messenger for service to sensor messages.
     */
    final Messenger mMessenger = new Messenger(new ClientIncomingHandler());


    /**
     * Class for interacting with the main interface of the service.
     */
    private ServiceConnection mConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className,
                IBinder service) {
            // This is called when the connection with the service has been
            // established, giving us the service object we can use to
            // interact with the service.  We are communicating with our
            // service through an IDL interface, so get a client-side
            // representation of that from the raw service object.
            mService = new Messenger(service);

            Log.i(addr, "Bound to service.");
            // We want to monitor the service for as long as we are
            // connected to it.
            try {
                Message msg = Message.obtain(null, MSG_REGISTER_CLIENT);
                msg.replyTo = mMessenger;
                // Address identifies the sensor, this sensor gets the same RID every time
                Bundle b = new Bundle();

                b.putString("address", addr);
                b.putString("version", "1");
                b.putString("id", id);
                msg.setData(b);
                mService.send(msg);

            } catch (RemoteException e) {
                // In this case the service has crashed before we could even
                // do anything with it; we can count on soon being
                // disconnected (and then reconnected if it can be restarted)
                // so there is no need to do anything here.
            }
        }

        public void onServiceDisconnected(ComponentName className) {
            // This is called when the connection with the service has been
            // unexpectedly disconnected -- that is, its process crashed.
            mService = null;
        }
    };

    public void doBindService(String packageName, String serviceName) {
        // Establish a connection with the service.  We use an explicit
        // class name because there is no reason to be able to let other
        // applications replace our component.
        Intent i = new Intent();
        i.setClassName(packageName, serviceName);
        context.bindService(i, mConnection, Context.BIND_AUTO_CREATE);
        mIsBound = true;
    }

    public boolean isServiceConnected() {
        if (mService != null) return true;
        return false;
    }

    public void doUnbindService() {
        if (mIsBound) {
            // If we have received the service, and hence registered with
            // it, then now is the time to unregister.
            if (mService != null) {
                try {
                    Message msg = Message.obtain(null, MSG_UNREGISTER_CLIENT);
                    msg.replyTo = mMessenger;
                    Bundle b = new Bundle();
                    b.putString("address", addr);
                    b.putString("version", "1");
                    b.putString("id", id);
                    msg.setData(b);
                    mService.send(msg);
                } catch (RemoteException e) {
                    // There is nothing special we need to do if the service
                    // has crashed.
                }
            }

            // Detach our existing connection.
            context.unbindService(mConnection);
            mIsBound = false;
            mService = null;
        }
    }


}

