unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IniFiles;

type
  // Структура для каждого сегмента
  TSegment = record
    State: Boolean;     // Горит или нет
    ClickColor: TColor; // Цвет на карте кликов
    BitIndex: Byte;     // Индекс бита (из INI файла)
    Name: string;       // Имя для отладки
  end;

  TForm1 = class(TForm)
    Image1: TImage;
    edtBin: TEdit;
    edtHex: TEdit;
    Memo1: TMemo;
    BtnAdd: TButton;
    Label1: TLabel; // Защита от ошибки EClassNotFound
    Label2: TLabel; // Защита от ошибки EClassNotFound
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnAddClick(Sender: TObject);
  private
    Segments: array[0..7] of TSegment;
    ClickMap: TBitmap;
    procedure LoadConfig;
    procedure RecalculateCodes;
    procedure RedrawIndicator;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

// Загрузка матрицы сегментов из INI-файла
procedure TForm1.LoadConfig;
var
  Ini: TIniFile;
  Path: string;
begin
  Path := ExtractFilePath(ParamStr(0)) + 'config.ini';
  Ini := TIniFile.Create(Path);
  try
    Segments[0].BitIndex := Ini.ReadInteger('Mapping', 'A', 6);
    Segments[1].BitIndex := Ini.ReadInteger('Mapping', 'B', 7);
    Segments[2].BitIndex := Ini.ReadInteger('Mapping', 'C', 1);
    Segments[3].BitIndex := Ini.ReadInteger('Mapping', 'D', 2);
    Segments[4].BitIndex := Ini.ReadInteger('Mapping', 'E', 0);
    Segments[5].BitIndex := Ini.ReadInteger('Mapping', 'F', 4);
    Segments[6].BitIndex := Ini.ReadInteger('Mapping', 'G', 3);
    Segments[7].BitIndex := Ini.ReadInteger('Mapping', 'DP', 5);
  finally
    Ini.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Path: string;
  i: Integer;
begin
  Path := ExtractFilePath(ParamStr(0));
  
  // Очищаем Memo при старте
  Memo1.Clear;
  
  // Инициализируем карту кликов и загружаем её
  ClickMap := TBitmap.Create;
  if FileExists(Path + 'click_map.bmp') then
    ClickMap.LoadFromFile(Path + 'click_map.bmp')
  else
    ShowMessage('Ошибка: Файл click_map.bmp не найден!');

  // Привязываем цвета маски к сегментам
  Segments[0].ClickColor := RGB(0, 0, 255);     // A - Синий
  Segments[0].Name := 'A';
  Segments[1].ClickColor := RGB(0, 255, 0);     // B - Зелёный
  Segments[1].Name := 'B';
  Segments[2].ClickColor := RGB(255, 0, 0);     // C - Красный
  Segments[2].Name := 'C';
  Segments[3].ClickColor := RGB(255, 255, 0);   // D - Жёлтый
  Segments[3].Name := 'D';
  Segments[4].ClickColor := RGB(255, 0, 255);   // E - Фиолетовый
  Segments[4].Name := 'E';
  Segments[5].ClickColor := RGB(0, 255, 255);   // F - Голубой
  Segments[5].Name := 'F';
  Segments[6].ClickColor := RGB(128, 128, 128); // G - Серый
  Segments[6].Name := 'G';
  Segments[7].ClickColor := RGB(255, 128, 0);   // DP - Оранжевый
  Segments[7].Name := 'DP';

  // Включаем ВСЕ сегменты при старте программы
  for i := 0 to 7 do
  begin
    Segments[i].State := True;
  end;

  LoadConfig;
  
  // Рисуем зажженный индикатор и считаем биты для восьмерки с точкой
  RedrawIndicator;
  RecalculateCodes;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ClickMap.Free;
end;

// Перерисовка индикатора с диска (работает надежно)
procedure TForm1.RedrawIndicator;
var
  X, Y: Integer;
  TargetColor: TColor;
  i: Integer;
begin
  // Каждый раз перезагружаем чистый фон
  if FileExists(ExtractFilePath(ParamStr(0)) + 'bg.bmp') then
    Image1.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'bg.bmp')
  else
    Exit;

  // Сканируем картинку. Если сегмент включен, зажигаем его ярко-красным
  for Y := 0 to Image1.Height - 1 do
  begin
    for X := 0 to Image1.Width - 1 do
    begin
      TargetColor := ClickMap.Canvas.Pixels[X, Y];
      for i := 0 to 7 do
      begin
        if (Segments[i].ClickColor = TargetColor) and Segments[i].State then
        begin
          Image1.Canvas.Pixels[X, Y] := clRed;
        end;
      end;
    end;
  end;
end;

// Чистый пересчёт битов в BIN и HEX без лишних переменных
procedure TForm1.RecalculateCodes;
var
  ResultByte: Byte;
  BinStr: string;
  i: Integer;
begin
  ResultByte := 0;
  
  // Собираем байт на основе состояний сегментов и их битовых индексов
  for i := 0 to 7 do
  begin
    if Segments[i].State then
      ResultByte := ResultByte or (1 shl Segments[i].BitIndex);
  end;

  // Формируем красивую двоичную строку (от Бита 7 до Бита 0)
  BinStr := '';
  for i := 7 downto 0 do
  begin
    if (ResultByte and (1 shl i)) <> 0 then
      BinStr := BinStr + '1'
    else
      BinStr := BinStr + '0';
  end;

  edtBin.Text := '0b' + BinStr;
  edtHex.Text := '0x' + IntToHex(ResultByte, 2);
end;

// Обработка клика по наклонным сегментам
procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ColorUnderMouse: TColor;
  i: Integer;
begin
  ColorUnderMouse := ClickMap.Canvas.Pixels[X, Y];

  for i := 0 to 7 do
  begin
    if Segments[i].ClickColor = ColorUnderMouse then
    begin
      // Инвертируем состояние сегмента
      Segments[i].State := not Segments[i].State;
      RedrawIndicator;
      RecalculateCodes;
      Exit;
    end;
  end;
end;

// Кнопка сохранения строки в историю
procedure TForm1.BtnAddClick(Sender: TObject);
begin
  Memo1.Lines.Add('  ' + edtBin.Text + ', // ' + edtHex.Text);
end;

end.

