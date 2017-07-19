// Copyright 2016 Google Inc. All Rights Reserved.

package com.snowgrains.kaltiot.qtgooglecloudmsg;

import android.app.NativeActivity;
import android.content.Intent;
import android.util.Log;
import com.google.firebase.messaging.MessageForwardingService;
import org.qtproject.qt5.android.bindings.QtApplication;
import org.qtproject.qt5.android.bindings.QtActivity;


import android.content.Context;
import android.os.Bundle;
import android.util.Log;

/**
 * TestappNativeActivity is a NativeActivity that updates its intent when new intents are sent to
 * it.
 *
 * This is a workaround for a known issue that prevents the native C++ library from responding to
 * data payloads when both a data and notification payload are sent to the app while it is in the
 * background.
 */
public class TestappNativeActivity extends QtActivity {
  /**
   * Workaround for when a message is sent containing both a Data and Notification payload.
   *
   * When the app is in the foreground all data payloads are sent to the method
   * `::firebase::messaging::Listener::OnMessage`. However, when the app is in the background, if a
   * message with both a data and notification payload is receieved the data payload is stored on
   * the notification Intent. NativeActivity does not provide native callbacks for onNewIntent, so
   * it cannot route the data payload that is stored in the Intent to the C++ function OnMessage. As
   * a workaround, we override onNewIntent so that it forwards the intent to the C++ library's
   * service which in turn forwards the data to the native C++ messaging library.
   */

   @Override
   public void onCreate(Bundle savedInstanceState) {
       super.onCreate(savedInstanceState);
       Log.d("QTAPP", "onCreate");

   }

  @Override
  protected void onNewIntent(Intent intent) {
    Log.d("QTAPP", "onNewIntent!!!");
    Intent message = new Intent(this, MessageForwardingService.class);
    message.setAction(MessageForwardingService.ACTION_REMOTE_INTENT);
    message.putExtras(intent);
    startService(message);
    setIntent(intent);
  }
}
