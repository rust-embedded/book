#import "../config.typ": *

#h1((en: [Meet Your Hardware],
  de: [Lernen Sie Ihre Hardware kennen],
  ja: [ハードウェアとの出会い],
  uk: [Зустрічайте залізо],
  zh: [熟悉你的硬件],
), offset: whole)

#tr((
en: [
  Let's get familiar with the hardware we'll be working with.
],
de: [
  Machen wir uns mit der Hardware vertraut, mit der wir arbeiten werden.
],
ja: [
  これから作業するハードウェアに詳しくなりましょう。
],
uk: [
  Давайте ознайомимося з обладнанням, з яким ми будемо працювати.
],
zh: [
  先来熟悉下我们要用的硬件。
]))

#figure(
  image("../assets/f3.jpg")
)

= #tr((
  en: [STM32F3DISCOVERY (the "F3")],
  de: [STM32F3DISCOVERY (die "F3")],
  ja: [STM32F3DISCOVERY ("F3")],
  uk: [STM32F3DISCOVERY (скорочено "F3")],
  zh: [STM32F3DISCOVERY (the "F3")],
))

#tr((
en: [
  What does this board contain?
],
de: [
  Was beinhaltet diese Platine?
],
ja: [
  私たちは、本書内でこのボードを"F3"と呼びます。
],
uk: [
  Що міститься на цій платі?
],
zh: [
  这个板子有什么？
]))

#let url_f303 = "https://www.st.com/en/microcontrollers/stm32f303vc.html"
#let wiki_accelerometer = "https://en.wikipedia.org/wiki/Accelerometer"
#let url_lsm303 = "https://www.st.com/en/mems-and-sensors/lsm303dlhc.html"
#let wiki_magnetometer = "https://en.wikipedia.org/wiki/Magnetometer"
#let wiki_gyroscope = "https://en.wikipedia.org/wiki/Gyroscope"
#let url_l3gd20 = "https://www.pololu.com/file/0J563/L3GD20.pdf"
#let url_f103 = "https://www.st.com/en/microcontrollers/stm32f103cb.html"
#tr((
en: [
  - A #link(url_f303)[STM32F303VCT6] microcontroller. This microcontroller has
    - A single-core ARM Cortex-M4F processor with hardware support for
      single-precision floating point operations and a maximum clock
      frequency of 72 MHz.
    - 256 KiB of "Flash" memory. (1 KiB = 10#[*24*] bytes)
    - 48 KiB of RAM.
    - A variety of integrated peripherals such as timers, I2C, SPI and
      USART.
    - General purpose Input Output (GPIO) and other types of pins
      accessible through the two rows of headers along side the board.
    - A Mini-USB interface accessible through the USB port labeled "USB
      USER".
  - An #link(wiki_accelerometer)[accelerometer] as part of the #link(url_lsm303)[LSM303DLHC] chip.
  - A #link(wiki_magnetometer)[magnetometer] as part of the #link(url_lsm303)[LSM303DLHC] chip.
  - A #link(wiki_gyroscope)[gyroscope] as part of the #link(url_l3gd20)[L3GD20] chip.
  - 8 user LEDs arranged in the shape of a compass.
  - A second microcontroller: a #link(url_f103)[STM32F103].
    This microcontroller is actually part of an on-board programmer /
    debugger and is connected to the Mini-USB port named "USB ST-LINK".
],
de: [
  - Ein #link(url_f303)[STM32F303VCT6]-Mikrocontroller.
    Dieser Mikrocontroller hat
    - Ein Single-Core-ARM-Cortex-M4F-Prozessor mit Hardware-Unterstützung
      für Gleitkommaoperationen einfacher Genauigkeit und einer maximalen
      Taktfrequenz von 72 MHz.
    - 256 KiB "Flash"-Speicher. (1 KiB = 10#[*24*] bytes)
    - 48 KiB RAM.
    - Eine Vielzahl integrierter Peripherieeinheiten wie Timer, I2C, SPI
      und USART.
    - GPIO-Pins (General Purpose Input/Output) und andere Pin-Typen, die
      über die beiden Stiftleistenreihen an den Seiten der Platine
      zugänglich sind.
    - Einen #link(wiki_accelerometer)[Beschleunigungsmesser] als Teil des #link(url_lsm303)[LSM303DLHC]-Chips.
    - Ein #link(wiki_magnetometer)[Magnetfeldstärkenmessgerät] als Teil des #link(url_lsm303)[LSM303DLHC]-Chips.
      gekennzeichneten USB-Anschluss zugänglich ist.
  - Ein #link(wiki_accelerometer)[Beschleunigungssensor] als Teil des #link(url_lsm303)[LSM303DLHC]-Chips. #todoupd("de")
  - Ein #link(wiki_gyroscope)[Gyroskop] als Teil des
    #link(url_l3gd20)[L3GD20]-Chips.
  - 8 Benutzer-LEDs, angeordnet in Form eines Kompasses.
  - Ein zweiter Mikrocontroller: ein
    #link(url_f103)[STM32F103].
    Dieser Mikrocontroller ist eigentlich Teil eines
    On-Board-Programmers/Debuggers und mit dem Mini-USB-Anschluss namens
    „USB ST-LINK" verbunden.
],
ja: [
  このボードには何が搭載されているか見てみましょう。
  - STM32F303VCT6マイクロコントローラが1つ。このマイクロコントローラは、次のものを搭載しています。
    - 単精度浮動小数点演算をハードウェアサポートし、最大72MHzのクロック周波数で動作するシングルコアのARM
      Cortex-M4Fプロセッサ
    - 256 KiBの"フラッシュ"メモリ (1 KiB = 10#[*24*] bytes)
    - 48 KiBのRAM
    - 多くの"ペリフェラル": タイマ、GPIO、I2C、SPI、USART、他
    - 両側面の"ヘッダ"に配置された多数の"ピン"
    - *重要* このマイクロコントローラは、約3.3ボルトで動作します。
  - #link(wiki_accelerometer)[加速度センサ]と#link(wiki_magnetometer)[磁気センサ]が1つずつ
    (1つのパッケージにまとめられています)
  - #link(wiki_gyroscope)[ジャイロセンサ]が1つ
  - 円形に配置された8個のユーザLED
  - 第2のマイクロコントローラ:
    STM32F103CBT。このマイクロコントローラは、実際には、ST-LINKというオンボードプログラマおよびデバッガの一部であり、"USB
    ST-LINK"という名前のUSBポートに接続されています。
  - "USB
    USER"というラベルが付いている第2のUSBポート。このUSBポートは、メインマイクロコントローラ
    (STM32F303VCT6)に接続されており、アプリケーションで利用できます。
],
uk: [
  - Мікроконтролер #link(url_f303)[STM32F303VCT6]. Цей мікроконтролер має:
    - Одноядерний процесор ARM Cortex-M4F з апаратною підтримкою операцій
      з плаваючою комою одинарної точності і максимальною тактовою частотою 72 МГц.
    - 256 KiB флеш-пам'яті. (1 KiB = 10#[*24*] байт)
    - 48 KiB оперативної пам'яті.
    - Різноманітні інтегровані периферійні пристрої, такі як таймери, I2C, SPI та USART.
    - Піни вводу-виводу загального призначення (GPIO) та інші типи пінів,
      доступні через дворядні гребінки уздовж бокових стінок плати.
    - Інтерфейс USB, доступний через порт USB з позначкою "USB USER".
  - #link(wiki_accelerometer)[Акселерометр] у складі мікросхеми #link(url_lsm303)[LSM303DLHC].
  - #link(wiki_magnetometer)[Магнітометр] у складі мікросхеми #link(url_lsm303)[LSM303DLHC].
  - #link(wiki_gyroscope)[Гіроскоп] у складі мікросхеми #link(url_l3gd20)[L3GD20].
  - 8 користувацьких світлодіодів, розташованих у формі компаса.
  - Другий мікроконтролер: #link(url_f103)[STM32F103].
    Цей мікроконтролер фактично є частиною програматора/відладчика, розміщеного на платі, і підключений до USB-порту з назвою "USB ST-LINK".
],
zh: [
  - 一个#link(url_f303)[STM32F303VCT6]微控制器。这个微控制器包含
    - 一个单核的ARM Cortex-M4F
      处理器，支持单精度浮点运算，72MHz的最大时钟频率。
    - 256 KiB的"Flash"存储。
    - 48 KiB的RAM
    - 多种多样的外设，比如计时器，I2C，SPI和USART
    - 通用GPIO和在板子两侧的其它类型的引脚
    - 一个写着"USB USER"的USB接口
  - 一个位于#link(url_lsm303)[LSM303DLHC]芯片上的#link(wiki_accelerometer)[加速度计]。
  - 一个位于#link(url_lsm303)[LSM303DLHC]芯片上的#link(wiki_magnetometer)[磁力计]。
  - 一个位于#link(url_l3gd20)[L3GD20]芯片上的#link(wiki_gyroscope)[陀螺仪].
  - 8个摆得像一个指南针形状的user LEDs。
  - 一个二级微控制器:
    #link(url_f103)[STM32F103]。这个微控制器实际上是一个板载编程器/调试器的一部分，与名为"USB
    ST-LINK"的USB端口相连。
]))

#let url_f3disco = "https://www.st.com/en/evaluation-tools/stm32f3discovery.html"
#tr((
en: [
  For a more detailed list of features and further specifications of the
  board take a look at the #link(url_f3disco)[STMicroelectronics] website.
],
de: [
  Eine detailliertere Liste der Funktionen und weitere technische Daten
  des Boards finden Sie auf der Website von #link(url_f3disco)[STMicroelectronics].
],
uk: [
  Більш детальний перелік функцій та специфікацій плати можна знайти
  на сайті #link(url_f3disco)[STMicroelectronics].
],
zh: [
  关于所列举的功能的更多细节和开发板的更多规格请查阅#link(url_f3disco)[STMicroelectronics]网站。
]))


#let url_f303_ds = "https://www.st.com/resource/en/datasheet/stm32f303vc.pdf"
#tr((
en: [
  A word of caution: be careful if you want to apply external signals to
  the board. The microcontroller STM32F303VCT6 pins take a nominal voltage
  of 3.3 volts. For further information consult the
  #link(url_f303_ds)[6.2 Absolute maximum ratings section in the manual]
],
de: [
  Ein wichtiger Hinweis: Seien Sie vorsichtig, wenn Sie externe Signale an
  das Board anlegen möchten. Die Pins des Mikrocontrollers STM32F303VCT6
  sind für eine Nennspannung von 3,3 Volt ausgelegt. Weitere Informationen
  finden Sie im Abschnitt „6.2 Absolute maximum ratings" (Absolute
  Grenzwerte) im #link(url_f303_ds)[Datenblatt].
],
uk: [
  Застереження: будьте обережні, подаючи на плату зовнішні сигнали.
  Виводи мікроконтролера STM32F303VCT6 мають номінальну напругу 3,3 вольта.
  Для отримання додаткової інформації зверніться до розділу #link(url_f303_ds)[6.2 Absolute maximum ratings section у Reference Manual]
],
zh: [
  提醒一句:
  如果想要为板子提供外部信号，请小心。微控制器STM32F303VCT6管脚的标称电压是3.3伏。更多信息请查看#link(url_f303_ds)[6.2 Absolute maximum ratings section in the manual]。
]))