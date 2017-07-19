package com.snowgrains.radarsensor;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.ActivityManager;
import android.app.Service;
import android.app.PendingIntent;
import android.app.AlarmManager;
import android.app.NotificationManager;
import android.os.Messenger;
import android.os.Message;
import android.os.Handler;
import android.os.IBinder;
import android.os.Bundle;
import android.os.SystemClock;
import android.os.RemoteException;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.location.Location;
import android.util.Log;
import android.content.res.Configuration;
import android.content.pm.PackageManager;
import android.content.pm.PackageInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Scanner;
import java.io.File;
import java.io.FileWriter;
import java.io.BufferedWriter;

// We use KaltiotSmartGatewayApi to connect to KaltiotSmartGateway
import com.kaltiot.smartgatewayapi.KaltiotSmartGatewayApi;
import com.kaltiot.smartgatewayapi.KaltiotSmartGatewayApiCallbacks;
import com.snowgrains.radarsensor.KaltiotWrapper;

public class KaltiotService extends Service implements KaltiotSmartGatewayApiCallbacks {

    private static final String TAG = "AndroidRadarSensor0001";

    // Kaltiot Android Service running in the background, must be installed as separate .APK
    String servicePackage = "com.kaltiot.smartgateway";
    KaltiotSmartGatewayApi ksg = null;	// API for the Service

    // Google Account name used as customer_id for this sensor
    String address = "KaltiotService_0001";

    // Current connection info received from the Service
    int mState = 0;
    String mRid = "";
    String mAppid = "";

    // The sensor UI is client for this service
    Messenger mClients = null;




    @Override
    public void onCreate() {


        // Address, customer_id and capabilities for this sensor app
        String[] capabilities = { "AndroidKaltiotServiceTest" };
        ksg = new KaltiotSmartGatewayApi(servicePackage, TAG, address, capabilities, this, this);


        // Increase our priority to prevent from getting killed when running on background
        Thread thr = getMainLooper().getThread();
        Log.i(TAG, "Priority="+thr.getPriority());
        if (thr.getPriority() < 8) thr.setPriority(thr.getPriority()+2);



        // Start service so it will run indefinitely on the background
        ksg.startService();

        // Bind to MqService to register and receive notifications
        ksg.doBindService();
    }

    @Override
    public void onDestroy() {
        shutdown();

    }

    private void shutdown() {

        ksg.doUnbindService();
    }

    /**
     * Allow starting the service so that it keeps running on the background even
     * if the sensor UI is closed. This is to receive location information on background.
     */
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }





    public String getCurrentTimeString() {
        Calendar c = Calendar.getInstance();
        return c.get(Calendar.HOUR_OF_DAY)+"."+
               c.get(Calendar.MINUTE)+":"+
               c.get(Calendar.SECOND);
    }



    /* Callback methods from KaltiotSmartGatewayApiCallbacks interface */
    public void state_callback(int state, int error) {
        mState = state;
        Log.i(TAG, "STATE="+state);
        // Update the UI
        Message msg = createMessage("", getConnectionState(), KaltiotWrapper.MSG_SET_STATE);
        sendMessage(msg);
    }

    public boolean isOnline() {
        if (mState == 3)
            return true;
        else
            return false;
    }

    public String getConnectionState() {
        if (mState == 3)
            return "online";
        if (mState == 2)
            return "offline";
        return "no network";
    }

    public void rid_callback(String address, final String rid) {
        // Pass through to UI
        mRid = rid;
         Log.i(TAG, "RID="+rid);
        Message msg = createMessage(address, rid, KaltiotWrapper.MSG_SET_RID);
        sendMessage(msg);
    }

    public void appid_callback(String address, final String appid) {
        // Pass through to UI
        mAppid = appid;
        Message msg = createMessage(address, appid, KaltiotWrapper.MSG_SET_APPID);
        sendMessage(msg);
    }

    public void notification_callback(String address, byte[] payload,
                int payload_type, String msg_id) {
        // In this sample we handle the payload always as String
        String str = new String(payload);
        //Log.i(TAG, "Received notification payload_type="+payload_type+" length="+payload.length+" : "+str);
        // Pass the payload through to UI
        Message msg = createMessage(address, str, KaltiotWrapper.MSG_SEND_PAYLOAD);
        msg.arg1 = payload_type;
        sendMessage(msg);

        // Respond to ping
        if (payload_type == KaltiotWrapper.PAYLOAD_PING && address.equals(TAG)) {
            String publish = "pong";
            ksg.publish(publish.getBytes(), KaltiotWrapper.PAYLOAD_PONG);
            return;
        }

        if (payload_type != KaltiotWrapper.PAYLOAD_STRING)
            Log.i(TAG, "Received notification payload_type="+payload_type+" length="+payload.length+" : "+str);

        if (str == null) return;


    }


    // Action when sensor wants to publish a message
    void handleSensorMessage(int arg1, String str) {

    }

    /**
     * Handler of incoming messages from client (SensorActivity).
     */
    class ServiceIncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case KaltiotWrapper.MSG_REGISTER_CLIENT:
                    mClients = msg.replyTo;
                    String address = msg.getData().getString("address");
                    String version = msg.getData().getString("version");
                    String id = msg.getData().getString("id");
                    Log.i(TAG, "Sensor registered "+mClients );

                    break;
                case KaltiotWrapper.MSG_UNREGISTER_CLIENT:
                    mClients = null;
                    address = msg.getData().getString("address");
                    version = msg.getData().getString("version");
                    id = msg.getData().getString("id");
                    Log.i(TAG, "Sensor unregistered");
                    break;
                case KaltiotWrapper.MSG_SEND_PAYLOAD:
                    String str = msg.getData().getString("data");
                    if (isOnline()) {
                        handleSensorMessage(msg.arg1, str);
                    }
                    break;

                 default:
                    super.handleMessage(msg);
            }
        }
    }

    /**
     * Target we publish for clients to send messages to ServiceIncomingHandler.
     */
    final Messenger mMessenger = new Messenger(new ServiceIncomingHandler());

    /**
     * When client is binding to the service, we return an interface to our messenger
     * for sending messages to the service.
     */
    @Override
    public IBinder onBind(Intent intent) {
        Log.i(TAG, "Binding to client");
        return mMessenger.getBinder();
    }

    // Create a message to send to a client
    private Message createMessage(String address, String data, int what) {
        // Send the string as data in bundle
        Bundle b = new Bundle();
        b.putString("data", data);
        b.putString("address", address);
        Message msg = Message.obtain(null, what);
        msg.setData(b);
        return msg;
    }

    private Message createMessage(int value, int what) {
        // Send the value as msg.arg1
        Message msg = Message.obtain(null, what);
        msg.arg1 = value;
        return msg;
    }

    // Create a message for UI update
    private Message createUIUpdateMessage(String line1, String line2, String line3) {
        // Send the string as data in bundle
        Bundle b = new Bundle();
        b.putString("data", line1 + "\n" + line2 + "\n" + line3);
        b.putString("address", "");
        Message msg = Message.obtain(null, KaltiotWrapper.MSG_SET_VALUE);
        msg.setData(b);
        return msg;
    }

    // Send a message to our client
    public void sendMessage(Message msg) {
        if (mClients != null) {
            try {
                mClients.send(msg);
            } catch (RemoteException e) {
                mClients = null;
            }
        }
    }


}
