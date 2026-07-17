require "import"
import "android.widget.*"
import "android.app.*"
import "android.view.*"
import "java.util.*"
import "android.content.Intent"
import "android.net.Uri"
import "android.content.Context"
import "android.content.ClipData"
import "android.content.ClipboardManager"

local ctx = activity or service or this
if ctx == nil then return end

-- SharePreferences Setup to Remember Settings
local sp = ctx.getSharedPreferences("SmartCalendarPrefs", Context.MODE_PRIVATE)
local lang = sp.getString("selected_lang", "en")

local calendar = Calendar.getInstance()
local currentRealDate = calendar.get(Calendar.DAY_OF_MONTH)
local currentRealMonthIdx = calendar.get(Calendar.MONTH) + 1
local currentRealYear = calendar.get(Calendar.YEAR)
local currentRealDayIdx = calendar.get(Calendar.DAY_OF_WEEK)

-- Load last saved customized dates or default to current
local selectedDayIdx = sp.getInt("saved_day", currentRealDayIdx)
local selectedDateVal = sp.getInt("saved_date", currentRealDate)
local selectedMonthIdx = sp.getInt("saved_month", currentRealMonthIdx)
local selectedYearVal = sp.getInt("saved_year", currentRealYear)

-- Reference to main dialog to allow dismissing from sub-dialogs
local mainAppDialog = nil

local function safeShow(dialog)
  pcall(function()
    if dialog.getWindow then
      local win = dialog.getWindow()
      if win then
        win.setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
      end
    end
  end)
  dialog.show()
end

local function playStartupEffects()
  pcall(function()
    local vibrator = ctx.getSystemService(Context.VIBRATOR_SERVICE)
    if vibrator then vibrator.vibrate(100) end
  end)
  pcall(function()
    ctx.playSoundEffect(SoundEffectConstants.CLICK)
  end)
  pcall(function()
    local welcomeText = "Welcome Aftab Ali"
    if lang == "ur" then
      welcomeText = "خوش آمدید آفتاب علی"
    elseif lang == "sd" then
      welcomeText = "ڀلي ڪري آيا آفتاب علي"
    elseif lang == "hi" then
      welcomeText = "स्वागत है आफताब अली"
    elseif lang == "ar" then
      welcomeText = "أهلاً بك آفتاب علي"
    elseif lang == "pa" then
      welcomeText = "ਜੀ ਆਇਆਂ ਨੂੰ ਆਫ਼ਤਾਬ ਅਲੀ"
    end
    if service and service.speak then
      service.speak(welcomeText)
    elseif ctx.speak then
      ctx.speak(welcomeText)
    end
  end)
end

-- Function to open URL with App Chooser between WhatsApp and WhatsApp Business
local function openWhatsAppWithChooser(url)
  pcall(function()
    local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    
    -- Creating a list of targeted package intents for WhatsApp & WhatsApp Business
    local pm = ctx.getPackageManager()
    local mainIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
    
    local chooserIntent = Intent.createChooser(mainIntent, lang == "ur" and "واٹس ایپ منتخب کریں" or "Open with:")
    chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    ctx.startActivity(chooserIntent)
  end)
end

local function openUrl(url)
  local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
  intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
  ctx.startActivity(intent)
end

local function copyToClipboard(text)
  pcall(function()
    local clipboard = ctx.getSystemService(Context.CLIPBOARD_SERVICE)
    local clip = ClipData.newPlainText("CalendarDate", text)
    clipboard.setPrimaryClip(clip)
    
    local feedbackText = text .. " copied"
    if lang == "ur" then
      feedbackText = "تاریخ کاپی ہو گئی: " .. text
    elseif lang == "sd" then
      feedbackText = "تاريخ ڪاپي ٿي وئي: " .. text
    elseif lang == "hi" then
      feedbackText = "तारीख कॉपी हो गई: " .. text
    elseif lang == "ar" then
      feedbackText = "تم نسخ التاريخ: " .. text
    elseif lang == "pa" then
      feedbackText = "ਤਾਰੀਖ ਕਾਪੀ ਹੋ ਗਈ: " .. text
    end

    if service and service.speak then
      service.speak(feedbackText)
    end
    Toast.makeText(ctx, feedbackText, Toast.LENGTH_SHORT).show()
  end)
end

local function speakLocalized(text)
  pcall(function()
    if service and service.speak then
      service.speak(text)
    elseif ctx.speak then
      ctx.speak(text)
    end
  end)
end

local function T(k)
  local t={
    en={
      appName="Smart Calendar by CSR Expert",
      version="Version: 1.1",
      dev1="Developer: Mohammed Rehan",
      lang="Select Language",
      hijri="Hijri Calendar",
      greg="Gregorian Calendar",
      vikrami="Vikrami Calendar",
      about="About & Support",
      exit="Exit",
      close="Close",
      goback="Go Back",
      feedback="Send Feedback",
      copy_d="Copy Customizable Date",
      select_day="Select Day",
      select_month="Select Month",
      select_year="Select Year",
      select_date="Select Date Number",
      confirm="Save Changes",
      credits_title="Project Credits / Team Members",
      coming_soon_title="Upcoming Features (Coming Soon in V1.2):",
      coming_soon="1. Islamic Festivals & Important Days Alert.\n2. Original Desi Month Names for Vikrami Calendar.\n3. Daily Morning Date Notification Alert.\n4. Speaking Calendar (Voice Output Support)."
    },
    ur={
      appName="اسمارٹ کیلنڈر بائی سی ایس آر ایکسپرٹ",
      version="ورژن: 1.1",
      dev1="ڈیولپر: محمد ریحان",
      lang="زبان منتخب کریں",
      hijri="ہجری کیلنڈر",
      greg="عیسوی کیلنڈر",
      vikrami="بکرمی کیلنڈر",
      about="اباؤٹ اینڈ سپورٹ",
      exit="بند کریں (Exit)",
      close="بند کریں",
      goback="پیچھے جائیں",
      feedback="فیڈ بیک بھیجیں",
      copy_d="تاریخ کاپی کرو",
      select_day="دن منتخب کریں",
      select_month="مہینہ منتخب کریں",
      select_year="سال منتخب کریں",
      select_date="تاریخ منتخب کریں",
      confirm="تبدیلی محفوظ کریں",
      credits_title="پروجیکٹ کریڈٹس / ٹیم ممبرز",
      coming_soon_title="آنے والے نئے فیچرز (کمنگ سون ورژن 1.2):",
      coming_soon="1۔ اسلامی تہوار اور اہم دنوں کے الرٹس\n2۔ بکرمی کیلنڈر کے لیے اصل دیسی مہینوں کے الرٹ\n3۔ روزانہ صبح کی تاریخ کا الرٹ\n4۔ اسپیکنگ کیلنڈر"
    },
    sd={
      appName="سمارٽ ڪيلينڊر پاران سي ايس آر ايڪسپرٽ",
      version="ورجن: 1.1",
      dev1="ڊولپر: محمد ريحان",
      lang="ٻولي چونڊيو",
      hijri="هجري ڪيلينڊر",
      greg="عيسوي ڪيلينڊر",
      vikrami="بڪرمي ڪيلينڊر",
      about="پروگرام بابت ۽ مدد",
      exit="بند ڪريو (Exit)",
      close="بند ڪريو",
      goback="واپس وڃو",
      feedback="راءِ موڪليو",
      copy_d="تاريخ ڪاپي ڪريو",
      select_day="ڏينهن چونڊيو",
      select_month="مهينو چونڊيو",
      select_year="سال چونڊيو",
      select_date="تاريخ چونڊيو",
      confirm="تبديليون محفوظ ڪريو",
      credits_title="پروجيڪٽ ڪريڊٽ / ٽيم ميمبر",
      coming_soon_title="اچڻ واريون نيون خوبيون (ورجن 1.2):",
      coming_soon="1. اسلامي ڏڻ ۽ اهم ڏينهن جا الرٽ.\n2. بڪرمي ڪيلينڊر لاءِ اصل ديسي مهينن جا نالا.\n3. روزاني صبح جو تاريخ جو الرٽ.\n4. ڳالهائيندڙ ڪيلينڊر (آواز جي سهولت)."
    },
    hi={
      appName="स्मार्ट कैलेंडर बाय सीएसआर एक्सपर्ट",
      version="वर्जन: 1.1",
      dev1="डेवलपर: मोहम्मद रेहान",
      lang="भाषा चुनें",
      hijri="हिजरी कैलेंडर",
      greg="ग्रेगोरियन कैलेंडर",
      vikrami="विक्रमी कैलेंडर",
      about="ऐप के बारे में और सहायता",
      exit="बाहर निकलें (Exit)",
      close="बंद करें",
      goback="पीछे जाएं",
      feedback="प्रतिक्रिया भेजें",
      copy_d="तारीख कॉपी करें",
      select_day="दिन चुनें",
      select_month="महीना चुनें",
      select_year="वर्ष चुनें",
      select_date="तारीख चुनें",
      confirm="परिवर्तन सुरक्षित करें",
      credits_title="परियोजना क्रेडिट / टीम के सदस्य",
      coming_soon_title="आने वाले नए फीचर्स (वर्जन 1.2 में जल्द आ रहे हैं):",
      coming_soon="1. इस्लामिक त्यौहार और महत्वपूर्ण दिनों के अलर्ट।\n2. विक्रमी कैलेंडर के लिए मूल देसी महीनों के नाम।\n3. दैनिक सुबह की तारीख का अलर्ट।\n4. स्पीकिंग कैलेंडर (ध्वनि आउटपुट समर्थन)।"
    },
    ar={
      appName="التقويم الذكي من قبل سي إس آر إكسبرت",
      version="الإصدار: 1.1",
      dev1="المطور: محمد ريحان",
      lang="اختر اللغة",
      hijri="التقويم الهجري",
      greg="التقويم الميلادي",
      vikrami="التقويم الفيكرامي",
      about="حول البرنامج والدعم",
      exit="خروج",
      close="إغلاق",
      goback="رجوع",
      feedback="أرسل ملاحظاتك",
      copy_d="نسخ التاريخ المخصص",
      select_day="اختر اليوم",
      select_month="اختر الشهر",
      select_year="اختر السنة",
      select_date="اختر رقم اليوم",
      confirm="حفظ التغييرات",
      credits_title="طاقم العمل والائتمانات",
      coming_soon_title="الميزات القادمة (قريباً في الإصدار 1.2):",
      coming_soon="1. تنبيهات المناسبات الإسلامية والأيام الهامة.\n2. أسماء الأشهر الأصلية للتقويم الفيكرامي.\n3. تنبيه يومي صباحي بالتاريخ.\n4. التقويم الناطق (دعم الصوت)."
    },
    pa={
      appName="ਸਮਾਰਟ ਕੈਲੰਡਰ ਬਾਈ ਸੀਐੱਸਆਰ ਐਕਸਪਰਟ",
      version="ਵਰਜਨ: 1.1",
      dev1="ਡਿਵੈਲਪਰ: ਮੁਹੰਮਦ ਰੇਹਾਨ",
      lang="ਭਾਸ਼ਾ ਚੁਣੋ",
      hijri="ਹਿਜਰੀ ਕੈਲੰਡਰ",
      greg="ਗ੍ਰੇਗੋਰੀਅਨ ਕੈਲੰਡਰ",
      vikrami="ਬਿਕ੍ਰਮੀ ਕੈਲੰਡਰ",
      about="ਐਪ ਬਾਰੇ ਅਤੇ ਸਹਾਇਤਾ",
      exit="ਬਾਹਰ ਜਾਓ (Exit)",
      close="ਬੰਦ ਕਰੋ",
      goback="ਪਿੱਛੇ ਜਾਓ",
      feedback="ਫੀਡਬੈਕ ਭੇਜੋ",
      copy_d="ਤਾਰੀਖ ਕਾਪੀ ਕਰੋ",
      select_day="ਦਿਨ ਚੁਣੋ",
      select_month="ਮਹੀਨਾ ਚੁਣੋ",
      select_year="ਸਾਲ ਚੁਣੋ",
      select_date="ਤਾਰੀਖ ਚੁਣੋ",
      confirm="ਤਬਦੀਲੀਆਂ ਸੁਰੱਖਿਅਤ ਕਰੋ",
      credits_title="ਪ੍ਰੋਜੈਕਟ ਕ੍ਰੈਡਿਟ / ਟੀਮ ਮੈਂਬਰ",
      coming_soon_title="ਆਉਣ ਵਾਲੇ ਨਵੇਂ ਫੀਚਰ (ਵਰਜਨ 1.2 ਵਿੱਚ ਜਲਦੀ):",
      coming_soon="1. ਇਸਲਾਮੀ ਤਿਉਹਾਰ ਅਤੇ ਮਹੱਤਵਪੂਰਨ ਦਿਨਾਂ ਦੇ ਅਲਰਟ।\n2. ਬਿਕ੍ਰਮੀ ਕੈਲੰਡਰ ਲਈ ਅਸਲੀ ਦੇਸੀ ਮਹੀਨਿਆਂ ਦੇ ਨਾਮ।\n3. ਰੋਜ਼ਾਨਾ ਸਵੇਰੇ ਤਾਰੀਖ ਦਾ ਅਲਰਟ।\n4. ਸਪੀਕਿੰਗ ਕੈਲੰਡਰ (ਆਵਾਜ਼ ਸਹਾਇਤਾ)।"
    }
  }
  local currentLang = t[lang] or t["en"]
  return currentLang[k] or t["en"][k] or k
end

local g_months={
  en={"January","February","March","April","May","June","July","August","September","October","November","December"},
  ur={"جنوری","فروری","مارچ","اپریل","مئی","جون","جولائی","اگست","ستمبر","اکتوبر","نومبر","دسمبر"},
  sd={"جنوري","فيبروري","مارچ","اپريل","مئي","جون","جولائي","آگسٽ","سيپٽمبر","آڪٽوبر","نومبر","ڊسمبر"},
  hi={"जनवरी","फ़रवरी","मार्च","अप्रैल","मई","जून","जुलाई","अगस्त","सितंबर","अक्टूबर","नवंबर","दिसंबर"},
  ar={"يناير","فبراير","مارس","أبريل","مايو","يونيو","يوليو","أغسطس","سبتمبر","أكتوبر","نوفمبر","ديسمبر"},
  pa={"ਜਨਵਰੀ","ਫ਼ਰਵਰੀ","ਮਾਰਚ","ਅਪ੍ਰੈਲ","ਮਈ","ਜੂਨ","ਜੁਲਾਈ","ਅਗਸਤ","ਸਤੰਬਰ","ਅਕਤੂਬਰ","ਨਵੰਬਰ","ਦਸੰਬਰ"}
}

local h_months={
  en={"Muharram","Safar","Rabi I","Rabi II","Jumada I","Jumada II","Rajab","Shaban","Ramadan","Shawwal","Dhul Qadah","Dhul Hijjah"},
  ur={"محرم","صفر","ربیع الاول","ربیع الثانی","جمادی الاول","جمادی الثانی","رجب","شعبان","رمضان","شوال","ذوالقعدہ","ذوالحجہ"},
  sd={"محرم","صقر","ربيع الاول","ربيع الثاني","جمادي الاول","جمادي الثاني","رجب","شعبان","رمضان","شوال","ذوالقعده","ذوالحج"},
  hi={"मुहर्रम","सफ़र","रबी-उल-अव्वल","रबी-उल-थानी","जमाद-उल-अव्वल","जमाद-उल-थاني","रजब","शाबान","रमजान","शव्वाल","धुल-कादा","धुल-हिज्जा"},
  ar={"محرم","صفر","ربيع الأول","ربيع الثاني","جمادى الأولى","جمادى الآخرة","رجب","شعبان","رمضان","شوال","ذو القعدة","ذو الحجة"},
  pa={"ਮੁਹੱਰਮ","ਸਫ਼ਰ","ਰਬੀ ਉਲ ਅੱਵਲ","ਰਬੀ ਉਲ ਥਾਨੀ","ਜਮਾਦ ਉਲ ਅੱਵਲ","ਜਮਾਦ ਉਲ ਥਾਨੀ","ਰਜਬ","ਸ਼ਾਬਾਨ","ਰਮਜ਼ਾਨ","ਸ਼ੱਵਾਲ","ਜ਼ੁਲ ਕਾਦਾ","ਜ਼ੁਲ ਹਿੱਜਾ"}
}

local v_months={
  en={"Chet","Vaisakh","Jeth","Harh","Sawan","Bhadon","Asu","Katik","Magghar","Poh","Magh","Phagun"},
  ur={"چیت","ویساکھ","جیٹھ","ہاڑھ","ساون","भादों","آسو","کاتک","مگھر","پوہ","ماگھ","پھگن"},
  sd={"چيٽ","وياءُ","جيٺ","هاڙھ","ساوڻ","بڊو","اسو","ڪاتڪ","مگهر","پوهه","ماهه","ڦڳڻ"},
  hi={"चेत","वैशाख","जेठ","हाढ़","सावन","भादों","आसू","कातिक","मग्घर","पोह","माघ","फागुन"},
  ar={"شيت","فيساخ","جيث","هاره","ساوان","بهادون","آسو","كاتيك","ماغار","بوه","ماغ","فاجون"},
  pa={"ਚੇਤ","ਵੈਸਾਖ","ਜੇਠ","ਹਾੜ੍ਹ","ਸਾਵਣ","ਭਾਦੋਂ","ਅੱਸੂ","ਕੱਤਕ","ਮੱਘਰ","ਪੋਹ","ਮਾਘ","ਫੱਗਣ"}
}

local days={
  en={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"},
  ur={"اتوار","پیر","منگل","بدھ","جمعرات","جمعہ","ہفتہ"},
  sd={"آچر","سومر","اڱارو","اربع","خميس","جمعو","ڇنڇر"},
  hi={"रविवार","सोमवार","मंगलवार","बुधवार","गुरुवार","शुक्रवार","शनिवार"},
  ar={"الأحد","الإثنين","الثلاثاء","الأربعاء","الخميس","الجمعة","السبت"},
  pa={"ਐਤਵਾਰ","ਸੋਮਵਾਰ","ਮੰਗਲਵਾਰ","ਬੁੱਧਵਾਰ","ਵੀਰਵਾਰ","ਸ਼ੁੱਕਰਵਾਰ","ਸ਼ਨੀਵਾਰ"}
}

local function getLocalizedDateInfo(calendarType)
  local localDays = days[lang] or days["en"]
  local currentDayStr = localDays[currentRealDayIdx]

  if calendarType == "hijri" then
    local jd = math.floor(365.25 * (currentRealYear + 4716)) + math.floor(30.6001 * (currentRealMonthIdx + 1)) + currentRealDate - 1524.5
    if jd > 2299160 then
      local alpha = math.floor((currentRealYear - 1860) / 100)
      jd = jd + 1 + alpha - math.floor(alpha / 4)
    end
    local epoch = 1948439.5
    local l = jd - epoch + 10632
    local n = math.floor((l - 1) / 10631)
    l = l - 10631 * n + 354
    local j = (math.floor((10985 - l) / 5316)) * (math.floor((50 * l) / 17719)) + (math.floor(l / 5670)) * (math.floor((43 * l) / 15238))
    l = l - (math.floor((30 - j) / 15)) * (math.floor((17719 * j) / 50)) - (math.floor(j / 16)) * (math.floor((15238 * j) / 43)) + 29
    local m = math.floor((24 * l) / 709)
    local d = l - math.floor((709 * m) / 24)
    local y = 30 * n + j - 30

    if m < 1 then m = 1 elseif m > 12 then m = 12 end
    if d < 1 then d = 1 elseif d > 30 then d = 30 end

    return d, m, y, "AH", h_months[lang] or h_months["en"]

  elseif calendarType == "vikrami" then
    local vYear = currentRealYear + 57
    local vMonth = currentRealMonthIdx + 2
    if vMonth > 12 then
      vMonth = vMonth - 12
      vYear = vYear + 1
    end
    return currentRealDate, vMonth, vYear, "Bikrami", v_months[lang] or v_months["en"]

  else
    return currentRealDate, currentRealMonthIdx, currentRealYear, "AD", g_months[lang] or g_months["en"]
  end
end

-- SECURE GATEKEEPER DIALOG WITH AFTAB'S NUMBER (923425037026)
local function openSecureWhatsAppGate(aboutDialog)
  local verifyDlg = LuaDialog(ctx)
  verifyDlg.setTitle(lang == "ur" and "صارف کی تصدیق" or "User Verification")

  local container = LinearLayout(ctx)
  container.setOrientation(LinearLayout.VERTICAL)
  container.setPadding(40, 40, 40, 40)

  local infoTxt = TextView(ctx)
  infoTxt.setText(lang == "ur" and "سیکیورٹی کے لیے برائے مہربانی اپنا نام اور شہر لکھیں تاکہ ہم آپ کو گروپ میں شامل کر سکیں:" or "For security, please enter your Name and City to request group entry:")
  infoTxt.setTextSize(15)
  infoTxt.setPadding(0, 0, 0, 15)
  container.addView(infoTxt)

  local inputField = EditText(ctx)
  inputField.setHint(lang == "ur" and "نام اور شہر یہاں لکھیں..." or "Enter Name and City here...")
  container.addView(inputField)

  local btnSubmit = Button(ctx)
  btnSubmit.setText(lang == "ur" and "معلومات بھیجیں اور جوائن کریں" or "Submit & Join Group")
  btnSubmit.setOnClickListener(function()
    local textVal = tostring(inputField.getText())
    if textVal == "" or #textVal < 3 then
      Toast.makeText(ctx, lang == "ur" and "برائے مہربانی اپنا درست نام لکھیں!" or "Please enter a valid name!", Toast.LENGTH_SHORT).show()
    else
      -- Sends name details straight to AFTAB ALI'S WhatsApp Number (923425037026)
      local formattedMsg = "Hello Aftab Ali, I want to join the CSR Expert WhatsApp Group.\n\nMy Details:\n" .. textVal
      local encodedMsg = Uri.encode(formattedMsg)
      
      -- Open App chooser for WhatsApp & WhatsApp Business
      openWhatsAppWithChooser("https://wa.me/923425037026?text=" .. encodedMsg)
      
      -- Dismissing all active dialogs to exit application seamlessly
      verifyDlg.dismiss()
      if aboutDialog then aboutDialog.dismiss() end
      if mainAppDialog then mainAppDialog.dismiss() end
      
      local linkDlg = LuaDialog(ctx)
      linkDlg.setTitle(lang == "ur" and "گروپ لنک" or "Group Link")
      
      local innerLayout = LinearLayout(ctx)
      innerLayout.setOrientation(LinearLayout.VERTICAL)
      innerLayout.setPadding(35, 35, 35, 35)
      
      local successText = TextView(ctx)
      successText.setText(lang == "ur" and "شکریہ! اب آپ نیچے بٹن پر کلک کر کے گروپ جوائن کر سکتے ہیں:" or "Thank you! You can now join the group using the button below:")
      successText.setPadding(0,0,0,15)
      innerLayout.addView(successText)
      
      local joinBtn = Button(ctx)
      joinBtn.setText(lang == "ur" and "واٹس ایپ گروپ جوائن کریں" or "Join WhatsApp Group Now")
      joinBtn.setOnClickListener(function()
        openWhatsAppWithChooser("https://chat.whatsapp.com/CqaHmbOTNkEFzDXZ8Vtzlz")
        linkDlg.dismiss()
      end)
      innerLayout.addView(joinBtn)
      
      linkDlg.setView(innerLayout)
      safeShow(linkDlg)
    end
  end)
  container.addView(btnSubmit)

  verifyDlg.setView(container)
  safeShow(verifyDlg)
end

-- DYNAMIC CUSTOMIZER WITH SAVE RETENTION
local function showIndependentCustomizer(calendarKey, calendarTitle)
  local currentActiveDate, currentActiveMonthIdx, currentActiveYear, yearSuffix, monthNames = getLocalizedDateInfo(calendarKey)

  local dlg = LuaDialog(ctx)
  dlg.setTitle(calendarTitle)

  local layout = LinearLayout(ctx)
  layout.setOrientation(LinearLayout.VERTICAL)
  layout.setPadding(35, 35, 35, 35)

  local localDays = days[lang] or days["en"]

  local realDateHeader = TextView(ctx)
  realDateHeader.setTextSize(16)
  realDateHeader.setPadding(0, 10, 0, 20)
  realDateHeader.setGravity(Gravity.CENTER)
  layout.addView(realDateHeader)

  local function refreshLivePreview()
    local currentDayStr = localDays[selectedDayIdx]
    local currentMonthStr = monthNames[selectedMonthIdx]
    realDateHeader.setText("📅 Selected: " .. currentDayStr .. ", " .. selectedDateVal .. " " .. currentMonthStr .. " " .. selectedYearVal .. " " .. yearSuffix)
  end

  refreshLivePreview()

  local btnSelectDate = Button(ctx)
  btnSelectDate.setText(T("select_date") .. ": " .. selectedDateVal)
  btnSelectDate.setOnClickListener(function()
    local dateDlg = LuaDialog(ctx)
    dateDlg.setTitle(T("select_date"))
    local scroll = ScrollView(ctx)
    local subLayout = LinearLayout(ctx)
    subLayout.setOrientation(LinearLayout.VERTICAL)
    
    for i=1, 30 do
      local itemBtn = Button(ctx)
      itemBtn.setText(tostring(i))
      if i == currentActiveDate then
        itemBtn.setText(tostring(i) .. " (Current)")
      end
      itemBtn.setOnClickListener(function()
        selectedDateVal = i
        btnSelectDate.setText(T("select_date") .. ": " .. selectedDateVal)
        refreshLivePreview()
        dateDlg.dismiss()
      end)
      subLayout.addView(itemBtn)
    end
    scroll.addView(subLayout)
    dateDlg.setView(scroll)
    safeShow(dateDlg)
  end)
  layout.addView(btnSelectDate)

  local btnSelectMonth = Button(ctx)
  btnSelectMonth.setText(T("select_month") .. ": " .. monthNames[selectedMonthIdx])
  btnSelectMonth.setOnClickListener(function()
    local mDlg = LuaDialog(ctx)
    mDlg.setTitle(T("select_month"))
    local scroll = ScrollView(ctx)
    local subLayout = LinearLayout(ctx)
    subLayout.setOrientation(LinearLayout.VERTICAL)
    
    for i, name in ipairs(monthNames) do
      local itemBtn = Button(ctx)
      itemBtn.setText(name)
      if i == currentActiveMonthIdx then
        itemBtn.setText(name .. " (Current)")
      end
      itemBtn.setOnClickListener(function()
        selectedMonthIdx = i
        btnSelectMonth.setText(T("select_month") .. ": " .. monthNames[selectedMonthIdx])
        refreshLivePreview()
        mDlg.dismiss()
      end)
      subLayout.addView(itemBtn)
    end
    scroll.addView(subLayout)
    mDlg.setView(scroll)
    safeShow(mDlg)
  end)
  layout.addView(btnSelectMonth)

  local btnSelectYear = Button(ctx)
  btnSelectYear.setText(T("select_year") .. ": " .. selectedYearVal)
  btnSelectYear.setOnClickListener(function()
    local yDlg = LuaDialog(ctx)
    yDlg.setTitle(T("select_year"))
    local scroll = ScrollView(ctx)
    local subLayout = LinearLayout(ctx)
    subLayout.setOrientation(LinearLayout.VERTICAL)
    
    local minYear = selectedYearVal - 5
    local maxYear = selectedYearVal + 15
    for i=minYear, maxYear do
      local itemBtn = Button(ctx)
      itemBtn.setText(tostring(i))
      if i == currentActiveYear then
        itemBtn.setText(tostring(i) .. " (Current)")
      end
      itemBtn.setOnClickListener(function()
        selectedYearVal = i
        btnSelectYear.setText(T("select_year") .. ": " .. selectedYearVal)
        refreshLivePreview()
        yDlg.dismiss()
      end)
      subLayout.addView(itemBtn)
    end
    scroll.addView(subLayout)
    yDlg.setView(scroll)
    safeShow(yDlg)
  end)
  layout.addView(btnSelectYear)

  local btnSelectDay = Button(ctx)
  btnSelectDay.setText(T("select_day") .. ": " .. localDays[selectedDayIdx])
  btnSelectDay.setOnClickListener(function()
    local dDlg = LuaDialog(ctx)
    dDlg.setTitle(T("select_day"))
    local scroll = ScrollView(ctx)
    local subLayout = LinearLayout(ctx)
    subLayout.setOrientation(LinearLayout.VERTICAL)
    
    for i, name in ipairs(localDays) do
      local itemBtn = Button(ctx)
      itemBtn.setText(name)
      if i == currentRealDayIdx then
        itemBtn.setText(name .. " (Current)")
      end
      itemBtn.setOnClickListener(function()
        selectedDayIdx = i
        btnSelectDay.setText(T("select_day") .. ": " .. localDays[selectedDayIdx])
        refreshLivePreview()
        dDlg.dismiss()
      end)
      subLayout.addView(itemBtn)
    end
    scroll.addView(subLayout)
    dDlg.setView(scroll)
    safeShow(dDlg)
  end)
  layout.addView(btnSelectDay)

  local confirmBtn = Button(ctx)
  confirmBtn.setText(T("confirm"))
  confirmBtn.setOnClickListener(function()
    local editor = sp.edit()
    editor.putInt("saved_date", selectedDateVal)
    editor.putInt("saved_month", selectedMonthIdx)
    editor.putInt("saved_year", selectedYearVal)
    editor.putInt("saved_day", selectedDayIdx)
    editor.commit()

    local finalDayStr = localDays[selectedDayIdx]
    local finalMonthStr = monthNames[selectedMonthIdx]
    local combinedText = finalDayStr .. ", " .. selectedDateVal .. " " .. finalMonthStr .. " " .. selectedYearVal .. " " .. yearSuffix

    speakLocalized(combinedText)
    Toast.makeText(ctx, combinedText, Toast.LENGTH_LONG).show()
  end)
  layout.addView(confirmBtn)

  local copyBtn = Button(ctx)
  copyBtn.setText(T("copy_d"))
  copyBtn.setOnClickListener(function()
    local finalDayStr = localDays[selectedDayIdx]
    local finalMonthStr = monthNames[selectedMonthIdx]
    local combinedText = finalDayStr .. ", " .. selectedDateVal .. " " .. finalMonthStr .. " " .. selectedYearVal .. " " .. yearSuffix
    copyToClipboard(combinedText)
  end)
  layout.addView(copyBtn)

  local closeBtn = Button(ctx)
  closeBtn.setText(T("close"))
  closeBtn.setOnClickListener(function() dlg.dismiss() end)
  layout.addView(closeBtn)

  dlg.setView(layout)
  safeShow(dlg)
end

-- MAIN INTERFACE
function openApp()
  playStartupEffects()
  mainAppDialog = LuaDialog(ctx)
  
  local mainView = LinearLayout(ctx)
  mainView.setOrientation(LinearLayout.VERTICAL)
  mainView.setPadding(40, 40, 40, 40)
  
  local txtAppName = TextView(ctx)
  txtAppName.setText(T("appName"))
  txtAppName.setTextSize(20)
  txtAppName.setGravity(Gravity.CENTER)
  txtAppName.setPadding(0, 10, 0, 5)
  mainView.addView(txtAppName)
  
  local txtVersion = TextView(ctx)
  txtVersion.setText(T("version"))
  txtVersion.setTextSize(16)
  txtVersion.setGravity(Gravity.CENTER)
  txtVersion.setPadding(0, 0, 0, 5)
  mainView.addView(txtVersion)
  
  local txtDev1 = TextView(ctx)
  txtDev1.setText(T("dev1"))
  txtDev1.setTextSize(14)
  txtDev1.setGravity(Gravity.CENTER)
  txtDev1.setPadding(0, 0, 0, 20)
  mainView.addView(txtDev1)
  
  local buttonsLayout = loadlayout{
    LinearLayout; orientation="vertical";
    
    {Button; text=T("lang"); onClick=function()
      local dlg = LuaDialog(ctx)
      dlg.setTitle("Language")
      dlg.setView(loadlayout{
        LinearLayout; orientation="vertical";
        {Button; text="English"; onClick=function() 
          lang="en" 
          sp.edit().putString("selected_lang", "en").commit()
          dlg.dismiss() mainAppDialog.dismiss() openApp() 
        end},
        {Button; text="Urdu"; onClick=function() 
          lang="ur" 
          sp.edit().putString("selected_lang", "ur").commit()
          dlg.dismiss() mainAppDialog.dismiss() openApp() 
        end},
        {Button; text="Sindhi"; onClick=function() 
          lang="sd" 
          sp.edit().putString("selected_lang", "sd").commit()
          dlg.dismiss() mainAppDialog.dismiss() openApp() 
        end},
        {Button; text="Hindi"; onClick=function() 
          lang="hi" 
          sp.edit().putString("selected_lang", "hi").commit()
          dlg.dismiss() mainAppDialog.dismiss() openApp() 
        end},
        {Button; text="Arabic"; onClick=function() 
          lang="ar" 
          sp.edit().putString("selected_lang", "ar").commit()
          dlg.dismiss() mainAppDialog.dismiss() openApp() 
        end},
        {Button; text="Punjabi"; onClick=function() 
          lang="pa" 
          sp.edit().putString("selected_lang", "pa").commit()
          dlg.dismiss() mainAppDialog.dismiss() openApp() 
        end},
        {Button; text=T("close"); onClick=function() dlg.dismiss() end},
      })
      safeShow(dlg)
    end},
    
    {Button; text=T("hijri"); onClick=function() 
      showIndependentCustomizer("hijri", T("hijri")) 
    end},
    
    {Button; text=T("greg"); onClick=function() 
      showIndependentCustomizer("gregorian", T("greg")) 
    end},
    
    {Button; text=T("vikrami"); onClick=function() 
      showIndependentCustomizer("vikrami", T("vikrami")) 
    end},
    
    {Button; text=T("about"); onClick=function()
      local dlg = LuaDialog(ctx)
      dlg.setTitle(T("about"))
      
      local aboutLayout = LinearLayout(ctx)
      aboutLayout.setOrientation(LinearLayout.VERTICAL)
      aboutLayout.setPadding(30, 30, 30, 30)
      
      local scroll = ScrollView(ctx)
      scroll.setFillViewport(true)
      
      local aTitle = TextView(ctx)
      aTitle.setText(T("appName"))
      aTitle.setTextSize(18)
      aTitle.setGravity(Gravity.CENTER)
      aboutLayout.addView(aTitle)
      
      local aVer = TextView(ctx)
      aVer.setText(T("version"))
      aVer.setTextSize(15)
      aVer.setGravity(Gravity.CENTER)
      aboutLayout.addView(aVer)
      
      local aDev1 = TextView(ctx)
      aDev1.setText(T("dev1").."\n")
      aDev1.setTextSize(14)
      aDev1.setGravity(Gravity.CENTER)
      aboutLayout.addView(aDev1)

      local btnCredits = Button(ctx)
      btnCredits.setText(T("credits_title"))
      btnCredits.setOnClickListener(function()
        local creditsDlg = LuaDialog(ctx)
        creditsDlg.setTitle(T("credits_title"))
        
        local creditsLayout = LinearLayout(ctx)
        creditsLayout.setOrientation(LinearLayout.VERTICAL)
        creditsLayout.setPadding(30, 30, 30, 30)
        
        local creditsText = TextView(ctx)
        creditsText.setTextSize(16)
        creditsText.setText(
          "✨ Team Credits List:\n\n" ..
          "1. Mohammed Rehan (Original Lead Developer & Creator)\n" ..
          "2. Aftab Ali (Project Manager & Code Upgrader)\n" ..
          "3. Mohsin Ali (Associate Contributor)"
        )
        creditsLayout.addView(creditsText)
        
        local btnCloseCredits = Button(ctx)
        btnCloseCredits.setText(T("close"))
        btnCloseCredits.setOnClickListener(function() creditsDlg.dismiss() end)
        creditsLayout.addView(btnCloseCredits)
        
        creditsDlg.setView(creditsLayout)
        safeShow(creditsDlg)
      end)
      aboutLayout.addView(btnCredits)
      
      local comingSoonTitle = TextView(ctx)
      comingSoonTitle.setText(T("coming_soon_title"))
      comingSoonTitle.setTextSize(15)
      comingSoonTitle.setPadding(0, 10, 0, 5)
      aboutLayout.addView(comingSoonTitle)
      
      local comingSoonText = TextView(ctx)
      comingSoonText.setText(T("coming_soon").."\n")
      comingSoonText.setTextSize(14)
      aboutLayout.addView(comingSoonText)
      
      -- FEEDBACK DIRECT TO ORIGINAL DEVELOPER (Mohammed Rehan: 923305415734)
      local btnFeedback = Button(ctx)
      btnFeedback.setText(T("feedback"))
      btnFeedback.setOnClickListener(function() openWhatsAppWithChooser("https://wa.me/923305415734") end)
      aboutLayout.addView(btnFeedback)
      
      local btnATVOld = Button(ctx)
      btnATVOld.setText("Accessible Tech Vision (WhatsApp Channel)")
      btnATVOld.setOnClickListener(function() openUrl("https://whatsapp.com/channel/0029Vb7IpqF23n3oxCl4ts25") end)
      aboutLayout.addView(btnATVOld)

      local btnCSRGroup = Button(ctx)
      btnCSRGroup.setText("CSR Expert WhatsApp Group")
      btnCSRGroup.setOnClickListener(function() openSecureWhatsAppGate(dlg) end)
      aboutLayout.addView(btnCSRGroup)
      
      local btnCSRChannel = Button(ctx)
      btnCSRChannel.setText("CSR Expert WhatsApp Channel")
      btnCSRChannel.setOnClickListener(function() openUrl("https://whatsapp.com/channel/0029VbCfIq3Fi8xXRpRxqP1B") end)
      aboutLayout.addView(btnCSRChannel)
      
      local btnATVYoutube = Button(ctx)
      btnATVYoutube.setText("Accessible Tech Vision YouTube")
      btnATVYoutube.setOnClickListener(function() openUrl("https://www.youtube.com/@accessibleTechvision") end)
      aboutLayout.addView(btnATVYoutube)
      
      local btnCSRYoutube = Button(ctx)
      btnCSRYoutube.setText("CSR Expert YouTube Channel")
      btnCSRYoutube.setOnClickListener(function() openUrl("https://youtube.com/@csrexpert-d5v?si=xi-Ch7BYEzpJ5bTq") end)
      aboutLayout.addView(btnCSRYoutube)
      
      local spacer = TextView(ctx)
      spacer.setText("\n")
      aboutLayout.addView(spacer)
      
      local btnBack = Button(ctx)
      btnBack.setText(T("goback"))
      btnBack.setOnClickListener(function() dlg.dismiss() end)
      aboutLayout.addView(btnBack)
      
      scroll.addView(aboutLayout)
      dlg.setView(scroll)
      safeShow(dlg)
    end},
    
    {Button; text=T("exit"); onClick=function() mainAppDialog.dismiss() end},
  }
  
  mainView.addView(buttonsLayout)
  mainAppDialog.setView(mainView)
  safeShow(mainAppDialog)
end

openApp()