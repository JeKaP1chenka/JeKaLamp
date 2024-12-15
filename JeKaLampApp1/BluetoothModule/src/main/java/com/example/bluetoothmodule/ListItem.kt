package com.example.bluetoothmodule

import android.bluetooth.BluetoothClass.Device
import android.bluetooth.BluetoothDevice

data class ListItem(
    val device: BluetoothDevice,
//    val name: String,
//    val mac: String,
    val isChecked: Boolean,
)
