unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, lNetComponents, IniFiles, process, md5;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    LSMTPClientComponent1: TLSMTPClientComponent;
    LSSLSessionComponent1: TLSSLSessionComponent;
    Memo1: TMemo;
    Panel1: TPanel;
    Process1: TProcess;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    default_id_operat : integer;
    default_nm_operat : string;
    acrobat_path      : string;

    em_smtp  : string;
    em_port  : string;
    em_login : string;
    em_pass  : string;
    em_email : string;

    procedure SaveConfig;
    procedure LoadConfig;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
   Unit2, Unit4, unit6, Unit10;

{ TForm1 }

// wysylanie emaila
procedure TForm1.Button2Click(Sender: TObject);
var
  l : TListItem;
begin
  form2.default_id_operat:=form1.default_id_operat;
  form2.default_nm_operat:=form1.default_nm_operat;
  form2.Edit1.Text:='';
  form2.Edit2.Text:='';
  form2.SynEdit1.ClearAll;
  form2.SynEdit1.Lines.AddStrings(form4.memo1.Lines);
  form2.ListView1.Clear;
  if paramcount > 0 then
  begin
    l:=form2.ListView1.Items.Add;
    form2.Edit2.Text:='Dokument: '+ExtractFileName(paramstr(1));
    l.caption:=ExtractFileName(paramstr(1));
    l.SubItems.Add(ExtractFilePath(paramstr(1)));
  end;
  form2.bytes_sent:=0;
  form2.bytes_total:=0;
  form2.ProgressBar1.Position:=0;
  form2.StaticText1.Caption:='0.00%';
  form2.ShowModal;
end;

// podgląd PDF w Acrobacie
procedure TForm1.Button1Click(Sender: TObject);
begin
  if paramcount = 0 then
  begin
    ShowMessage('Program uruchomiony bezposrednio, brak parametru do podgladu.');
    exit;
  end;
  if process1.Active then process1.Terminate(0);
  process1.CommandLine:=form1.acrobat_path+' "'+paramstr(1)+'"';
//  ShowMessage(process1.CommandLine);
  process1.Execute;
end;

//konfiguracja
procedure TForm1.Button3Click(Sender: TObject);
begin
  form4.default_id_operat:=form1.default_id_operat;
  form4.default_nm_operat:=form1.default_nm_operat;
  form4.acrobat_path     :=form1.acrobat_path;
  form4.Panel2.Caption   :=form1.acrobat_path;

  form4.ShowModal;
  if form4.default_id_operat <> -1 then
  begin
    form1.default_id_operat:=form4.default_id_operat;
    form1.default_nm_operat:=form4.default_nm_operat;
    form1.acrobat_path     :=form4.acrobat_path;

    form1.Caption:='WanKom 0.1 ('+IntToStr(form1.default_id_operat)+') '+form1.default_nm_operat;
  end;

  SaveConfig;
end;

// koniec pracy
procedure TForm1.Button4Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  form9.default_id_operat:=form1.default_id_operat;
  form9.default_nm_operat:=form1.default_nm_operat;

  form9.acrobat_path:=acrobat_path;
  form9.ShowModal;
end;

// zapis konfiguracji
procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveConfig;
  SaveFormState('main',TForm(form1));
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  LoadConfig;
  LoadFormState('main',TForm(form1));
  form1.Caption:='WanKom 0.1 ('+IntToStr(form1.default_id_operat)+') '+form1.default_nm_operat;
  memo1.Lines.Clear;
  if paramcount <> 0 then memo1.Lines.Add(ParamStr(1));
end;

procedure TForm1.SaveConfig;
var
  ini : TIniFile;
  exe : string;
begin
  exe:=ExtractFilePath(ParamStr(0));
  if exe[length(exe)] <> '\' then exe:=exe+'\';

  ini:=TIniFile.Create(exe+'config.ini');
  ini.WriteInteger('ustawienia','id_operatora', form1.default_id_operat );
  ini.WriteString('ustawienia','nazwa_operatora', form1.default_nm_operat);
  ini.WriteString('ustawienia','acrobat_path',form1.acrobat_path);

  em_smtp  :=form4.Edit2.Text;
  em_port  :=form4.Edit3.Text;
  em_login :=form4.Edit4.Text;
  em_pass  :=form4.Edit5.Text;
  em_email :=form4.Edit6.Text;

  ini.WriteString('email','smtp',em_smtp);
  ini.WriteString('email','port',em_port);
  ini.WriteString('email','login',em_login);
  ini.WriteString('email','pass',em_pass);
  ini.WriteString('email','email',em_email);
  form4.memo1.Lines.SaveToFile(exe+'sygnaturka.txt');
  ini.Free;
end;

procedure TForm1.LoadConfig;
var
  ini : TIniFile;
  exe : string;
begin
  exe:=ExtractFilePath(ParamStr(0));
  if exe[length(exe)] <> '\' then exe:=exe+'\';

  ini:=TIniFile.Create(exe+'config.ini');
  default_id_operat:= ini.ReadInteger('ustawienia','id_operatora',-1);
  default_nm_operat:=ini.ReadString('ustawienia','nazwa_operatora','');
  acrobat_path     :=ini.ReadString('ustawienia','acrobat_path','');

  em_smtp  :=ini.ReadString('email','smtp','');
  em_port  :=ini.ReadString('email','port','587');
  em_login :=ini.ReadString('email','login','');
  em_pass  :=ini.ReadString('email','pass','');
  em_email :=ini.ReadString('email','email','');

  form4.Edit2.Text:=em_smtp;
  form4.Edit3.Text:=em_port;
  form4.Edit4.Text:=em_login;
  form4.Edit5.Text:=em_pass;
  form4.Edit6.Text:=em_email;

//  form3.Edit2.Text:=em_smtp;
//  form3.Edit3.Text:=em_port;
//  form3.Edit4.Text:=em_login;
//  form3.Edit5.Text:=em_pass;
//  form3.Edit6.Text:=em_email;

  form2.em_smtp:=em_smtp;
  form2.em_port:=em_port;
  form2.em_login:=em_login;
  form2.em_pass:=em_pass;
  form2.em_email:=em_email;

  ini.Free;

  if fileexists(exe+'sygnaturka.txt') then form4.memo1.Lines.LoadFromFile(exe+'sygnaturka.txt');

end;

end.

