unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, lNetComponents, lMimeWrapper, lSMTP, lNet;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    ListView1: TListView;
    OpenDialog1: TOpenDialog;
    Panel11: TPanel;
    Panel12: TPanel;
    ProgressBar1: TProgressBar;
    smtp: TLSMTPClientComponent;
    LSSLSessionComponent1: TLSSLSessionComponent;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    StaticText1: TStaticText;
    SynEdit1: TSynEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LSSLSessionComponent1SSLConnect(aSocket: TLSocket);
    procedure smtpConnect(aSocket: TLSocket);
    procedure smtpDisconnect(aSocket: TLSocket);
    procedure smtpError(const msg: string; aSocket: TLSocket);
    procedure smtpFailure(aSocket: TLSocket; const aStatus: TLSMTPStatus);
    procedure smtpReceive(aSocket: TLSocket);
    procedure smtpSent(aSocket: TLSocket; const Bytes: Integer);
    procedure smtpSuccess(aSocket: TLSocket; const aStatus: TLSMTPStatus);
  private
    { private declarations }
  public
    { public declarations }
    default_id_operat : integer;
    default_nm_operat : string;

    em_smtp  : string;
    em_port  : string;
    em_login : string;
    em_pass  : string;
    em_email : string;

    FMimeStream: TMimeStream;

    bytes_sent, bytes_total : Int64;

    procedure StoreEmail;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

uses
   unit3, unit6, unit7, unit9;
{ TForm2 }

procedure TForm2.Button4Click(Sender: TObject);
var
  a,b : string;
begin
  form3.default_id_operat:=form2.default_id_operat;
  form3.default_nm_operat:=form2.default_nm_operat;

  if (form3.ShowModal = mrOK) or (form3.ModalResult = mrOK) then
  begin
    a:=trim(form3.Dbf1.FieldByName('podstemail').AsString);
    b:=trim(form3.Dbf1.FieldByName('dodatemail').AsString);

    if (a <> '') and (b <> '') then
    begin
      form6.Label2.Caption:=a;
      form6.Label3.Caption:=b;
      form6.Label4.Caption:=a+','+b;
      form6.ShowModal;
      edit1.Text:=form6.email;
    end
    else
      if a <> '' then edit1.Text:=a
      else
        if b <> '' then edit1.Text:=b
        else
          begin
            edit1.Text:='';
            ShowMessage('Wybrany kontakt nie posiada adresu email !');
          end;
  end;
end;

// wysylanie email
procedure TForm2.Button3Click(Sender: TObject);
var
  pp  : word;

  cnt : byte;
  aaa : boolean;
  bbb : boolean;
  i   : integer;

begin
  FMimeStream := TMimeStream.Create;
//  FMimeStream.AddTextSection(''); // for the memo

  pp:=Word(StrToInt(em_port));
  smtp.Connect(em_smtp, pp);
  application.ProcessMessages;
  sleep(500);
  cnt:=20; // ilosc powtorzen
  repeat
    smtp.CallAction;
    dec(cnt);
    application.ProcessMessages;
    sleep(500);
    aaa:=smtp.Connected;
  until (cnt = 0) or aaa;

//  SynEdit1.Lines.AddStrings(SMTP.FeatureList);
  application.ProcessMessages;
  sleep(500);

  bbb:=SMTP.HasFeature('AUTH LOGIN');
  sleep(500);
  if bbb then
  begin
    SMTP.AuthLogin(em_login, em_pass);
    application.ProcessMessages;
    sleep(500);
  end
  else
  begin
    bbb:=SMTP.HasFeature('AUTH PLAIN');
    if bbb then
    begin
      SMTP.AuthPlain(em_login, em_pass);
      application.ProcessMessages;
      sleep(500);
    end;
  end;

  if aaa then
  begin
    FMimeStream.Reset; // make sure we can read it again

//    for i:=0 to SynEdit1.Lines.Count do TMimeTextSection(FMimeStream[i]).Text:=SynEdit1.Lines[i];
    for i:=0 to SynEdit1.Lines.Count do FMimeStream.AddTextSection(SynEdit1.Lines[i]);

    // dodoawanie zalacznikow
    for i:=0 to ListView1.Items.Count-1 do
    begin
      FMimeStream.AddFileSection(ListView1.Items[i].SubItems[0] + ListView1.Items[i].Caption);
      bytes_sent:=0;
      bytes_total:=FMimeStream.Size;
    end;

    StaticText1.Caption:='0.00%';
    ProgressBar1.Min:=0;
    ProgressBar1.Max:=bytes_total;
    form8.ProgressBar1.Min:=0;
    form8.ProgressBar1.Max:=bytes_total;

    form8.Show;
    application.ProcessMessages;
    sleep(200);

//    SynEdit1.Lines.Add('pruba wyslania email');

    SMTP.SendMail(em_email, edit1.Text+','+em_email, edit2.Text, FMimeStream); // send the stream
    application.ProcessMessages;
    sleep(200);
//    SynEdit1.Lines.Add('rozlaczanie');
//    SMTP.Disconnect();
//    application.ProcessMessages;
//    sleep(500);

  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  i  : integer;
  l  : TListItem;
  nm : string;
begin
  if OpenDialog1.Execute then
  begin
    for i:=0 to OpenDialog1.Files.Count-1 do
    begin
      nm:=OpenDialog1.Files[i];
      l:=ListView1.Items.Add;
      l.Caption:=ExtractFileName(nm);
      l.SubItems.Add(ExtractFilePath(nm));
    end;
  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  if ListView1.ItemIndex < 0 then exit;
  if MessageDlg('Pytanie', 'Na pewno skasować?', mtConfirmation,
   [mbYes, mbNo],0) = mrYes Then
   ListView1.Items.Delete(ListView1.ItemIndex);
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (bytes_sent >= bytes_total) and (bytes_total <> 0) then CloseAction:=caHide
  else
  if (trim(edit1.Text) <> '') or (trim(edit2.Text) <> '') or
     (SynEdit1.Lines.Count <> 0) or (ListView1.Items.Count <> 0)
  then
    begin
      if MessageDlg('Pytanie', 'Czy na pewno chcesz zrezygnować z tworzenia wiadmosci ?', mtConfirmation, [mbYes, mbNo],0) = mrNo
      Then CloseAction:=caNone else CloseAction:=caHide;
    end;
  SaveFormState('newemail',TForm(form2));
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  form2.Caption:='WanKom 0.1 ('+IntToStr(form2.default_id_operat)+') '+form2.default_nm_operat;
  LoadFormState('newemail',TForm(form2));
end;

procedure TForm2.LSSLSessionComponent1SSLConnect(aSocket: TLSocket);
begin
  smtp.Ehlo();
end;

procedure TForm2.smtpConnect(aSocket: TLSocket);
begin
//  SynEdit1.Lines.Add('Podlaczony');
end;

procedure TForm2.smtpDisconnect(aSocket: TLSocket);
begin
//  SynEdit1.Lines.Add('Rozlaczony');
  form8.Close;
  form2.Close;
end;

procedure TForm2.smtpError(const msg: string; aSocket: TLSocket);
begin
//  SynEdit1.Lines.Add('err: '+msg);
end;

procedure TForm2.smtpFailure(aSocket: TLSocket; const aStatus: TLSMTPStatus);
begin
//
end;

procedure TForm2.smtpReceive(aSocket: TLSocket);
var
    s : string;
begin
  if SMTP.GetMessage(s) > 0 then begin
//    SynEdit1.Lines.Append(s);
  end;
end;

procedure TForm2.smtpSent(aSocket: TLSocket; const Bytes: Integer);
begin
  bytes_sent:=bytes_sent+bytes;
  if bytes_total > 0 then StaticText1.Caption:=FormatFloat('#,##0.00',(bytes_sent/bytes_total)*100)+'%';
  ProgressBar1.Position:=bytes_sent;
  form8.ProgressBar1.Position:=bytes_sent;
end;

procedure TForm2.smtpSuccess(aSocket: TLSocket; const aStatus: TLSMTPStatus);
begin
  case aStatus of
    ssCon : begin
              if SMTP.HasFeature('EHLO') then // check for EHLO support
                SMTP.Ehlo(em_smtp)
              else
                SMTP.Helo(em_smtp);
            end;
//    ssEhlo: RefreshFeatureList;

//    ssAuthLogin,
//    ssAuthPlain : ButtonAuth.Visible := False;

    ssData: begin
              MessageDlg('Wiadomosc wyslana poprawnie !', mtInformation, [mbOK], 0);
              sleep(100);
              smtp.Disconnect();
              form2.FMimeStream.Free;
              StoreEmail;
            end;
    ssQuit: begin
              SMTP.Disconnect;
            end;
  end;
end;

procedure TForm2.StoreEmail;
var
   i                  : integer;
   exe,prefix         : string;
   r,ms,d,g,mn,s,s100 : word;
   f                  : TextFile;

   function LZ(txt : string;alen : integer):string;
   begin
     while length(txt) < alen do txt:='0'+txt;
     LZ:=txt;
   end;

begin
  exe:=ExtractFilePath(ParamStr(0));
  if exe[length(exe)] <> '\' then exe:=exe+'\';

  DecodeDate(Date(), r,ms,d);
  DecodeTime(Time(), g,mn,s,s100);

  prefix:=IntToStr(r)+'-'+LZ(IntToStr(ms),2)+'-'+LZ(IntToStr(d),2)+' '+
          LZ(IntToStr(g),2)+'_'+LZ(IntToStr(mn),2)+'_'+LZ(IntToStr(s),2)+'_'+LZ(IntToStr(s),3);

  // zapis tresci wiadomosci
  SynEdit1.Lines.SaveToFile(exe+'wiadomosci'+'\'+prefix+'#'+'nagl.txt');
  // zapis adresatow i tematu
  AssignFile(f,exe+'wiadomosci'+'\'+prefix+'#'+'adres.txt');
  rewrite(f);
  writeln(f,edit1.Text); // adresaci
  writeln(f,edit2.Text); // temat
  CloseFile(f);
  // zapis zalacznikow
  for i:=0 to ListView1.Items.Count - 1 do
  begin
    if not CopyFile(ListView1.Items[i].SubItems[0]+ListView1.Items[i].Caption,
             exe+'wiadomosci'+'\'+prefix+'#z#'+ListView1.Items[i].Caption,
             true)
    then
      ShowMessage('Nie udalo sie skopiowac zalacznika:'+#13#10+
                  ListView1.Items[i].SubItems[0]+ListView1.Items[i].Caption);

  end;

end;

end.

