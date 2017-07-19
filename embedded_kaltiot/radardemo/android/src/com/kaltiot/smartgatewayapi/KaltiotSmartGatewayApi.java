package com.kaltiot.smartgatewayapi;

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

public class KaltiotSmartGatewayApi {

    /* Payload types for notification callback and MSG_SEND_PAYLOAD
     * make sure to keep these in sync with PayloadType in mq_structs.h
     */
    public static final int PAYLOAD_BINARY = 1;
    public static final int PAYLOAD_INT = 2;
    public static final int PAYLOAD_STRING = 3;
    public static final int PAYLOAD_PING = 4;
    public static final int PAYLOAD_PONG = 5;

    /* Message.what values defined, used to pass messages from device (Android application) to
     * service (KaltiotSmartGateway) and vice versa: */

    /**
     * Message from device to service to register a device.
     * Message.replyTo must be a Messenger of the device where callbacks should be sent.
     * Message.getData().getString("address") stores the device's address.
     */
    public static final int MSG_REGISTER_CLIENT = 11;

    /**
     * Message from device to service to unregister a device.
     * Message.replyTo must be a Messenger of the device as previously given with MSG_REGISTER_CLIENT.
     * Message.getData().getString("address") stores the device's address.
     */
    public static final int MSG_UNREGISTER_CLIENT = 12;

    /**
     * Message for sending state from service to device.
     * Message.arg1 is the state.
     * Message.arg2 is the error value.
     * Message.getData().getString("address") stores the device's address.
     */
    public static final int MSG_SET_STATE = 13;

    /**
     * Message for sending a notification from service to device or
     * a publish from device to service.
     * Message.arg1 is the payload type.
     * Message.arg2 is the payload integer.
     * Message.getData().getByteArray("data") stores the payload as byte array.
     * Message.getData().getString("address") stores the device's address.
     * Message.getData().getString("id") stores the message ID from service to device.
     */
    public static final int MSG_SEND_PAYLOAD = 14;

    /**
     * Message for sending Resource ID from service to device.
     * Message.getData().getString("data") stores the device's unique RID.
     */
    public static final int MSG_SET_RID = 15;

    /**
     * Message for sending Application ID from service to device.
     * Message.getData().getString("data") stores the service's application ID.
     */
    public static final int MSG_SET_APPID = 16;

    /* Name of the Kaltiot Smart Gateway Android Service */
    private final String serviceName = "com.kaltiot.smartgateway.KaltiotSmartGateway";

    /* Members */
    String addr = null;
    String id = null;
    String[] capabilities = null;
    KaltiotSmartGatewayApiCallbacks appCb = null;
    Context context = null;
    String packageName = null;

    /** Messenger for communicating with service. */
    Messenger mService = null;
    /** Flag indicating whether we have called bind on the service. */
    boolean mIsBound = false;

    /**
     * Construct a connection with device information.
     *  @param packagename      Android .apk package name containing KaltiotSmartGateway
     *  @param address          Free name identifying this device
     *  @param customer_id      Unique identifier for this device, will be shown to the console
     *  @param capas            Capability keys, max 3
     *  @param cb               Object implementing the callbacks
     *  @param ctx              Android Context for this Android application
     */
    public KaltiotSmartGatewayApi(String packagename, String address, String customer_id,
                                  String[] capas, KaltiotSmartGatewayApiCallbacks cb, Context ctx) {
        packageName = packagename;
        addr = address;
        id = customer_id;
        capabilities = capas;
        appCb = cb;
        context = ctx;
    }

    /**
     * Start service on the background, this will keep the service always running.
     */
    public void startService() {
        Intent i = new Intent();
        i.setClassName("com.kaltiot.smartgateway", "com.kaltiot.smartgateway.KaltiotSmartGateway");
        context.startService(i);
    }

    /**
     * Establish a two-way connection with the service.
     * We use an explicit class name because we don't want to let other
     * applications replace our component.
     */
    public void doBindService() {
        Intent i = new Intent();
        i.setClassName("com.kaltiot.smartgateway", "com.kaltiot.smartgateway.KaltiotSmartGateway");
        context.bindService(i, mConnection, Context.BIND_AUTO_CREATE);
        mIsBound = true;
    }

    /**
     * Check if we are connected to KaltiotSmartGateway service.
     * @return true if the application is connected to the service. 
     */
    public boolean isServiceConnected() {
        if (mService != null) return true;
        return false;
    }

    /**
     * Unbind this device from the service.
     */
    public void doUnbindService() {
        if (mIsBound) {
            // If we have received the service, and hence registered with
            // it, then now is the time to unregister.
            if (mService != null) {
                /* Unregistering the device from service. The IoT device will still
                   remain in the mq_client. */
                try {
                    Message msg = Message.obtain(null, MSG_UNREGISTER_CLIENT);
                    msg.replyTo = mMessenger;
                    Bundle b = new Bundle();
                    b.putString("address", addr);
                    b.putString("version", "1");
                    b.putString("id", id);
                    b.putString("capa1", "");
                    b.putString("capa2", "");
                    b.putString("capa3", "");
                    msg.setData(b);
                    mService.send(msg);
                } catch (RemoteException e) {
                    // There is nothing special we need to do if the service has crashed.
                }
            }

            // Detach our existing connection.
            context.unbindService(mConnection);
            mIsBound = false;
            mService = null;
        }
    }

    /**
     * Publish a binary payload from this device.
     * @param payload          Payload to publish
     * @param payload_type     Type of payload: PAYLOAD_STRING, PAYLOAD_BINARY, PAYLOAD_INT, PAYLOAD_PONG
     */
    public void publish(byte[] payload, int payload_type) {

        if (mService != null) try {
            Message msg = Message.obtain(null, MSG_SEND_PAYLOAD);
            Bundle b = new Bundle();
            b.putString("address", addr);
            b.putByteArray("data", payload);
            msg.arg1 = payload_type;
            msg.replyTo = mMessenger;
            msg.setData(b);
            mService.send(msg);
        } catch (RemoteException e) {
            // There is nothing special we need to do if the service has crashed.
        }
    }

    /**
     * Handler of incoming messages from KaltiotSmartGateway, issue the appropriate callback.
     * The application must implement the callback functions to handle these messages.
     */
    class IncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_SET_STATE:
                    //Log.i(addr, "Sate: "+msg.arg1+":"+msg.arg2);
                    appCb.state_callback(msg.arg1, msg.arg2);
                    break;
                case MSG_SEND_PAYLOAD:
                    byte[] payload = msg.getData().getByteArray("data");
                    String address = msg.getData().getString("address");
                    String msgid = msg.getData().getString("id");
                    //Log.i(addr, "Received "+msg.arg1+": "+payload);
                    appCb.notification_callback(address, payload, msg.arg1, msgid);
                    break;
                case MSG_SET_RID:
                    String rid = msg.getData().getString("data");
                    address = msg.getData().getString("address");
                    //Log.i(addr, "RID: "+rid);
                    appCb.rid_callback(addr, rid);
                    break;
                case MSG_SET_APPID:
                    String appid = msg.getData().getString("data");
                    address = msg.getData().getString("address");
                    //Log.i(addr, "AppID: "+appid);
                    appCb.appid_callback(addr, appid);
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    /**
     * Messenger for service to sensor messages.
     */
    final Messenger mMessenger = new Messenger(new IncomingHandler());

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

            //Log.i(addr, "Bound to service, registering.");
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
                if (capabilities != null && capabilities.length > 0 && capabilities[0].length() > 0)
                    b.putString("capa1", capabilities[0]);
                else
                    b.putString("capa1", "");

                if (capabilities != null && capabilities.length > 1 && capabilities[1].length() > 0)
                    b.putString("capa2", capabilities[1]);
                else
                    b.putString("capa2", "");

                if (capabilities != null && capabilities.length > 2 && capabilities[2].length() > 0)
                    b.putString("capa3", capabilities[2]);
                else
                    b.putString("capa3", "");

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
}
