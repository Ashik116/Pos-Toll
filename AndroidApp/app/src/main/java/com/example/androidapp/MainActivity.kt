package com.example.androidapp

import Code
import ExampleHostApi
import FlutterError
import MessageData
import MessageFlutterApi
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.widget.Button
import android.zyapi.CommonApi
import androidx.activity.ComponentActivity
import com.qs.uhf.uhfreaderlib.reader.Tools
import com.qs.uhf.uhfreaderlib.reader.UhfReader
import com.qs.uhf.uhfreaderlib.reader.UhfReaderDevice
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.lang.ref.WeakReference

private const val FLUTTER_ENGINE_ID = "module_flutter_engine"


private class PigeonApiImplementation: ExampleHostApi {
    private var mainActivityRef: WeakReference<MainActivity>? = null

    constructor(mainActivity: MainActivity) {
        mainActivityRef = WeakReference(mainActivity)
    }

    override fun getHostLanguage(): String {
        val mainActivity = mainActivityRef?.get()

        // Check if the MainActivity reference is still valid
        if (mainActivity != null) {
            // Access the getter from MainActivity
            val someValue = mainActivity.getSomeValue()
            Log.d("MainActivityValue", someValue.toString())
            return someValue
        }
        return "Kotlin"
    }

    override fun add(a: Long, b: Long): Long {
        val mainActivity = mainActivityRef?.get()

        if (a < 0L || b < 0L) {
            throw FlutterError("code", "message", "details");
        }
        return a + b
    }

    override fun sendMessage(message: MessageData, callback: (Result<Boolean>) -> Unit) {
        if (message.code == Code.ONE) {
            callback(Result.failure(FlutterError("code", "message", "details")))
            return
        }
        callback(Result.success(true))
    }
}
// #enddocregion kotlin-class

// #docregion kotlin-class-flutter
private class PigeonFlutterApi {

    var flutterApi: MessageFlutterApi? = null

    constructor(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterApi = MessageFlutterApi(binding.getBinaryMessenger())
    }

    fun callFlutterMethod(aString: String, callback: (Result<String>) -> Unit) {
        flutterApi!!.flutterMethod(aString) {
                echo -> callback(Result.success("Hello"))
        }
    }
}


class MainActivity : ComponentActivity()  {
    private var currentEpcStr: String = ""
    lateinit var flutterEngine : FlutterEngine

    fun getSomeValue(): String {
        return currentEpcStr
    }

    private val handler = Handler(Handler.Callback { msg ->
        when (msg.what) {
            MESSAGE_EPC_RECEIVED -> {
                // Handle EPC String received from InventoryThread
                val epcStr = msg.obj as String
                runOnUiThread {
                    // Use PigeonApiImplementation on the main thread
                    currentEpcStr = epcStr
                    print(epcStr)
                }
            }
            // Handle other messages if needed
        }
        true
    })

    private var readerDevice // 读写器设备，抓哟操作读写器电源
            : UhfReaderDevice? = null
    private var screenReceiver: ScreenStateReceiver? = null

//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        val api = PigeonApiImplementation(this)
//        ExampleHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api);
//    }

    internal inner class InventoryThread(private val handler: Handler) : Thread() {
        private var epcList: List<ByteArray>? = null
       var runFlag=true

        override fun run() {
            super.run()
            while (runFlag) {
                if (startFlag) {
                    epcList = reader!!.inventoryRealTime() // 实时盘存
                    if (epcList != null && !epcList!!.isEmpty()) {
                        // 播放提示音
                        // player.start();
                        for (epc in epcList!!) {
                            if (epc != null) {
                                val epcStr = Tools.Bytes2HexString(
                                    epc,
                                    epc.size
                                )
                                handler.obtainMessage(MESSAGE_EPC_RECEIVED, epcStr).sendToTarget()
                            }
                        }
                    }
                    epcList = null
                    try {
                        sleep(40)
                    } catch (e: InterruptedException) {
                        // TODO Auto-generated catch block
                        //  e.printStackTrace()
                    }
                }
            }
        }
    }

    var player: MediaPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
//        startActivity(
//            withCachedEngine(FLUTTER_ENGINE_ID)
//                .build(this)
//        )
        // Instantiate a FlutterEngine
        flutterEngine = FlutterEngine(this)

        val api = PigeonApiImplementation(this)
        ExampleHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api);

        // Start executing Dart code to pre-warm the FlutterEngine
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )


        // Cache the FlutterEngine to be used by FlutterActivity
        FlutterEngineCache
            .getInstance()
            .put(FLUTTER_ENGINE_ID, flutterEngine)

        val myButton = findViewById<Button>(R.id.myButton)
        myButton.setOnClickListener {
            startActivity(
                FlutterActivity
                    .withCachedEngine(FLUTTER_ENGINE_ID)
                    .build(this)
            )
        }
        serialPortPath = "/dev/ttyMT2"
        mCommonApi = CommonApi()
        openGPIO()
        try {
            Thread.sleep(2000)
        } catch (e1: InterruptedException) {
            // TODO Auto-generated catch block
            e1.printStackTrace()
        }

        UhfReader.setPortPath(serialPortPath)
        reader = UhfReader.getInstance()

//        Toast.makeText(MainActivity.this, "" + reader.getPortPath(), Toast.LENGTH_SHORT).show();

        //设为欧洲频段
        reader?.setWorkArea(5)

        readerDevice = UhfReaderDevice.getInstance()
        if (reader == null) {
            return
        }
        if (readerDevice == null) {
            return
        }
        try {
            Thread.sleep(100)
        } catch (e: InterruptedException) {
            // TODO Auto-generated catch block
            e.printStackTrace()
        }
        // 获取用户设置功率,并设置
        val shared = getSharedPreferences("power", 0)
        val value = shared.getInt("value", 100)
        Log.d("", "value$value")
        reader!!.setOutputPower(value)

        // powerOn=true;
        // 添加广播，默认屏灭时休眠，屏亮时唤醒
        screenReceiver = ScreenStateReceiver()
        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_SCREEN_ON)
        filter.addAction(Intent.ACTION_SCREEN_OFF)

        val thread: Thread = InventoryThread(handler)
        thread.start()
        // 初始化声音播放器
       // player = MediaPlayer.create(this, R.raw.rfid)
    }
    companion object {
        private const val MESSAGE_EPC_RECEIVED = 1
        private var EPC_STRING = ""

        private var buttonStart: Button? = null
        var startFlag = true
        private var serialPortPath = "/dev/ttyS1"
        var reader // 超高频读写器
                : UhfReader? = null
        var mCommonApi: CommonApi? = null
        private const val mComFd = -1

        // 打开gpio
        fun openGPIO() {
            // TODO Auto-generated method stub
            mCommonApi!!.setGpioDir(78, 1)
            mCommonApi!!.setGpioOut(78, 1)
            mCommonApi!!.setGpioDir(83, 1)
            mCommonApi!!.setGpioOut(83, 1)
            mCommonApi!!.setGpioDir(68, 1)
            mCommonApi!!.setGpioOut(68, 1)

//        mCommonApi.setGpioDir(86, 1);
//        mCommonApi.setGpioOut(86, 1);
          //  buttonStart!!.setText(R.string.inventory)
        }

        // 关闭gpio
        fun closeGPIO() {
            mCommonApi!!.setGpioDir(78, 1)
            mCommonApi!!.setGpioOut(78, 0)
            mCommonApi!!.setGpioDir(83, 1)
            mCommonApi!!.setGpioOut(83, 0)
//        mCommonApi.setGpioDir(86, 1);
//        mCommonApi.setGpioOut(86, 0);
        }
    }

}

