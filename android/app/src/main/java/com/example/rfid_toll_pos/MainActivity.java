package com.example.rfid_toll_pos;

package com.magicrf.uhfreader;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;
import android.zyapi.CommonApi;

import com.android.hdhe.uhf.reader.R;
import com.qs.uhf.uhfreaderlib.reader.EPC;
import com.qs.uhf.uhfreaderlib.reader.Tools;
import com.qs.uhf.uhfreaderlib.reader.UhfReader;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends Activity implements OnClickListener,
        OnItemClickListener {

    private Button buttonClear;
    private Button buttonConnect;
    private static Button buttonStart;
    private Button button1;
    private TextView textVersion;
    private ListView listViewData;
    private ArrayList<EPC> listEPC;
    private ArrayList<Map<String, Object>> listMap;
    private boolean runFlag = true;
    public static boolean startFlag = false;
    private boolean connectFlag = false;
    private boolean powerOn = false;
    private static String serialPortPath = "/dev/ttyS1";
    public static UhfReader reader; // 超高频读写器
    private UhfReaderDevice readerDevice; // 读写器设备，抓哟操作读写器电源

    private ScreenStateReceiver screenReceiver;
    static CommonApi mCommonApi;
    private static int mComFd = -1;
    MediaPlayer player;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//		setOverflowShowingAlways();
        setContentView(R.layout.main);
        initView();
        // 获取读写器实例，若返回Null,则串口初始化失败
        SharedPreferences sharedPortPath = getSharedPreferences("portPath", 0);

//        serialPortPath = sharedPortPath.getString("portPath", "/dev/ttyMT2");

//        serialPortPath = sharedPortPath.getString("portPath", "/dev/ttyS1");

        serialPortPath = "/dev/ttyMT2";

        mCommonApi = new CommonApi();

        openGPIO();

        try {
            Thread.sleep(2000);
        } catch (InterruptedException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }

        UhfReader.setPortPath(serialPortPath);

        reader = UhfReader.getInstance();

//        Toast.makeText(MainActivity.this, "" + reader.getPortPath(), Toast.LENGTH_SHORT).show();

        //设为欧洲频段
        reader.setWorkArea(03);

        // 获取读写器设备示例，若返回null，则设备电源打开失败
        readerDevice = UhfReaderDevice.getInstance();
        if (reader == null) {
            textVersion.setText("serialport init fail");
            setButtonClickable(buttonClear, false);
            setButtonClickable(buttonStart, false);
            setButtonClickable(buttonConnect, false);
            return;
        }
        if (readerDevice == null) {
            textVersion.setText("UHF reader power on failed");
            setButtonClickable(buttonClear, false);
            setButtonClickable(buttonStart, false);
            setButtonClickable(buttonConnect, false);
            return;
        }
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        // 获取用户设置功率,并设置
        SharedPreferences shared = getSharedPreferences("power", 0);
        int value = shared.getInt("value", 26);
        Log.d("", "value" + value);
        reader.setOutputPower(value);

        // powerOn=true;
        // 添加广播，默认屏灭时休眠，屏亮时唤醒
        screenReceiver = new ScreenStateReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_SCREEN_ON);
        filter.addAction(Intent.ACTION_SCREEN_OFF);
        registerReceiver(screenReceiver, filter);

        button1 = (Button) findViewById(R.id.button1);
        button1.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
            }
        });

        setButtonClickable(buttonConnect, true);

        Thread thread = new InventoryThread();
        thread.start();
        // 初始化声音播放器
        player = MediaPlayer.create(this, R.raw.msg);

    }

    // 打开gpio
    public static void openGPIO() {
        // TODO Auto-generated method stub

        mCommonApi.setGpioDir(78, 1);
        mCommonApi.setGpioOut(78, 1);

        mCommonApi.setGpioDir(83, 1);
        mCommonApi.setGpioOut(83, 1);

        mCommonApi.setGpioDir(68, 1);
        mCommonApi.setGpioOut(68, 1);

//        mCommonApi.setGpioDir(86, 1);
//        mCommonApi.setGpioOut(86, 1);

        buttonStart.setText(R.string.inventory);

    }

    // 关闭gpio
    public static void closeGPIO() {

        mCommonApi.setGpioDir(78, 1);
        mCommonApi.setGpioOut(78, 0);

        mCommonApi.setGpioDir(83, 1);
        mCommonApi.setGpioOut(83,0);

//        mCommonApi.setGpioDir(86, 1);
//        mCommonApi.setGpioOut(86, 0);

    }

//    //打开gpio
//    public static void openGPIO() {
//        // TODO Auto-generated method stub
//        mCommonApi.setGpioDir(86,0);
//        mCommonApi.getGpioIn(86);
//
//        new Handler().postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                // TODO Auto-generated method stub
//                mCommonApi.setGpioDir(86,1);
//                mCommonApi.setGpioOut(86,1);
//
//                mCommonApi.setGpioDir(64,1);
//                mCommonApi.setGpioOut(64,0);
//
//                startFlag=true;
//
//            }
//        }, 500);
//
//        buttonStart.setText(R.string.stop_inventory);
//
//    }

    private void initView() {

        buttonStart = (Button) findViewById(R.id.button_start);
        buttonConnect = (Button) findViewById(R.id.button_connect);
        buttonClear = (Button) findViewById(R.id.button_clear);
        listViewData = (ListView) findViewById(R.id.listView_data);
        textVersion = (TextView) findViewById(R.id.textView_version);
        buttonStart.setOnClickListener(this);
        buttonConnect.setOnClickListener(this);
        buttonClear.setOnClickListener(this);
        setButtonClickable(buttonStart, true);
        setButtonClickable(buttonConnect, false);
        listEPC = new ArrayList<EPC>();
        listViewData.setOnItemClickListener(this);

    }

    /**
     * 盘存线程
     *
     * @author Administrator
     */
    class InventoryThread extends Thread {
        private List<byte[]> epcList;

        @Override
        public void run() {
            super.run();
            while (runFlag) {
                if (startFlag) {
                    epcList = reader.inventoryRealTime(); // 实时盘存
                    if (epcList != null && !epcList.isEmpty()) {
                        // 播放提示音
                        player.start();
                        for (byte[] epc : epcList) {
                            if (epc != null) {
                                String epcStr = Tools.Bytes2HexString(epc,
                                        epc.length);
                                addToList(listEPC, epcStr);
                            }
                        }
                    }
                    epcList = null;
                    try {
                        Thread.sleep(40);
                    } catch (InterruptedException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    // 将读取的EPC添加到LISTVIEW
    private void addToList(final List<EPC> list, final String epc) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // 第一次读入数据
                if (list.isEmpty()) {
                    EPC epcTag = new EPC();
                    epcTag.setEpc(epc);
                    epcTag.setCount(1);
                    list.add(epcTag);
                } else {
                    for (int i = 0; i < list.size(); i++) {
                        EPC mEPC = list.get(i);
                        // list中有此EPC
                        if (epc.equals(mEPC.getEpc())) {
                            mEPC.setCount(mEPC.getCount() + 1);
                            list.set(i, mEPC);
                            break;
                        } else if (i == (list.size() - 1)) {
                            // list中没有此epc
                            EPC newEPC = new EPC();
                            newEPC.setEpc(epc);
                            newEPC.setCount(1);
                            list.add(newEPC);
                        }
                    }
                }
                // 将数据添加到ListView
                listMap = new ArrayList<Map<String, Object>>();
                int idcount = 1;
                for (EPC epcdata : list) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    map.put("ID", idcount);
                    map.put("EPC", epcdata.getEpc());
                    map.put("COUNT", epcdata.getCount());
                    idcount++;
                    listMap.add(map);
                }
                listViewData.setAdapter(new SimpleAdapter(MainActivity.this,
                        listMap, R.layout.listview_item, new String[]{"ID",
                        "EPC", "COUNT"}, new int[]{R.id.textView_id,
                        R.id.textView_epc, R.id.textView_count}));
            }
        });
    }

    // 设置按钮是否可用
    private void setButtonClickable(Button button, boolean flag) {
        button.setClickable(flag);
        if (flag) {
            button.setTextColor(Color.BLACK);
        } else {
            button.setTextColor(Color.GRAY);
        }
    }

    @Override
    protected void onDestroy() {
        runFlag = false;
        if (reader != null) {
            reader.close();
        }
        if (readerDevice != null) {
            readerDevice.powerOff();
        }
        // unregisterReceiver(screenReceiver);
        closeGPIO();
        mCommonApi.closeCom(mComFd);
        Log.e("销毁界面", "销毁界面");
        super.onDestroy();
    }

    /**
     * 清空listview
     */
    private void clearData() {
        listEPC.removeAll(listEPC);
        listViewData.setAdapter(null);
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.button_start:
                if (!startFlag) {
                    startFlag = true;
                    buttonStart.setText(R.string.stop_inventory);
                } else {
                    startFlag = false;
                    buttonStart.setText(R.string.inventory);
                }
                break;
            case R.id.button_connect:

                byte[] versionBytes = reader.getFirmware();
                if (versionBytes != null) {
                    // reader.setWorkArea(3);//设置成欧标
                    player.start();
                    // String version = new String(versionBytes);
                    // textVersion.setText(new String(versionBytes));
                    setButtonClickable(buttonConnect, false);
                    setButtonClickable(buttonStart, true);
                }
                setButtonClickable(buttonConnect, false);
                setButtonClickable(buttonStart, true);
                break;

            case R.id.button_clear:
                clearData();
                break;
            default:
                break;
        }
    }

    private int value = 2600;

    // private int values = 432 ;
    // private int mixer = 0;
    // private int if_g = 0;

    @Override
    public void onItemClick(AdapterView<?> adapter, View view, int position,
                            long id) {
        TextView epcTextview = (TextView) view.findViewById(R.id.textView_epc);
        String epc = epcTextview.getText().toString();
        // 选择EPC
        // reader.selectEPC(Tools.HexString2Bytes(epc));

        Toast.makeText(getApplicationContext(), epc, Toast.LENGTH_SHORT).show();
        Intent intent = new Intent(this, MoreHandleActivity.class);
        intent.putExtra("epc", epc);
        startActivity(intent);
    }

    @Override
    public boolean onMenuItemSelected(int featureId, MenuItem item) {
        // Log.e("", "adfasdfasdf");
        Intent intent = new Intent(this, SettingActivity.class);
        startActivity(intent);
//		Intent intent = new Intent(this, SettingPower.class);
//		startActivity(intent);
        return super.onMenuItemSelected(featureId, item);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        getMenuInflater().inflate(R.menu.main, menu);

        return true;
    }

    @Override
    public boolean onMenuOpened(int featureId, Menu menu) {
        if (featureId == Window.FEATURE_ACTION_BAR && menu != null) {
            if (menu.getClass().getSimpleName().equals("MenuBuilder")) {

                try {
                    Method m = menu.getClass().getDeclaredMethod(
                            "setOptionalIconsVisible", Boolean.TYPE);
                    m.setAccessible(true);
                    m.invoke(menu, true);
                } catch (Exception e) {
                }
            }
        }
        return super.onMenuOpened(featureId, menu);
    }

//	/**
//	 * 在actionbar上显示菜单按钮
//	 */
//	private void setOverflowShowingAlways() {
//		try {
//			ViewConfiguration config = ViewConfiguration.get(MainActivity.this);
//			Field menuKeyField = ViewConfiguration.class
//					.getDeclaredField("sHasPermanentMenuKey");
//			menuKeyField.setAccessible(true);
//			menuKeyField.setBoolean(config, false);
//
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//	}

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_F1)
        {
            if (!startFlag) {
                startFlag = true;
                buttonStart.setText(R.string.stop_inventory);
            } else {
                startFlag = false;
                buttonStart.setText(R.string.inventory);
            }
        }
        return super.onKeyDown(keyCode, event);
    }

}
