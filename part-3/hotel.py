from kivy.app import App
from kivy.uix.widget import Widget
from kivy.core.window import Window
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.popup import Popup
from kivy.config import Config
from kivy.properties import ObjectProperty, StringProperty, BooleanProperty, ListProperty, NumericProperty
from kivy.uix.recyclegridlayout import RecycleGridLayout
from kivy.uix.behaviors import FocusBehavior
from kivy.uix.recycleview.views import RecycleDataViewBehavior
from kivy.uix.recycleview.layout import LayoutSelectionBehavior
import pyodbc
import os.path

Config.set('graphics', 'width', '1200')
Config.set('graphics', 'height', '700')
Config.write()

#
server = 'localhost' 
database = 'hotel' 
username = 'sa' 
password = 'dinara2001' 

db = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
cursor = db.cursor()


class RoomInfoUpd(Popup):
    obj = ObjectProperty(None)
    obj_text = StringProperty("")
    start_point = NumericProperty(0)
    col_data = ListProperty(["?", "?", "?"])

    def __init__(self, obj, **kwargs):
        super(RoomInfoUpd, self).__init__(**kwargs)
        self.obj = obj
        self.obj_text = obj.text
        self.start_point = obj.start_point
        self.col_data[0] = obj.rv_data[obj.start_point]["text"]
        self.col_data[1] = obj.rv_data[obj.start_point + 1]["text"]
        self.col_data[2] = obj.rv_data[obj.start_point + 2]["text"]


class BookingData(Popup):
    obj = ObjectProperty(None)
    start_point = NumericProperty(0)
    col_data = ListProperty(["?", "?", "?", "?"])


    def __init__(self, obj, **kwargs):
        super(BookingData, self).__init__(**kwargs)
        self.obj = obj
        self.start_point = obj.start_point
        self.col_data[0] = obj.rv_data[obj.start_point]["text"]
        self.col_data[1] = obj.rv_data[obj.start_point + 1]["text"]
        self.col_data[2] = obj.rv_data[obj.start_point + 2]["text"]
        self.col_data[3] = obj.rv_data[obj.start_point + 3]["text"]


class SelectableRecycleGridLayout(FocusBehavior, LayoutSelectionBehavior,
                                  RecycleGridLayout):
    ''' Adds selection and focus behaviour to the view. '''

class SelectableButton(RecycleDataViewBehavior, Button):
    ''' Add selection support to the Button '''
    index = None
    selected = BooleanProperty(False)
    selectable = BooleanProperty(True)

    def refresh_view_attrs(self, rv, index, data):
        ''' Catch and handle the view changes '''
        self.index = index
        return super(SelectableButton, self).refresh_view_attrs(rv, index, data)

    def on_touch_down(self, touch):
        ''' Add selection on touch down '''
        if super(SelectableButton, self).on_touch_down(touch):
            return True
        if self.collide_point(*touch.pos) and self.selectable:
            return self.parent.select_with_touch(self.index, touch)

    def apply_selection(self, rv, index, is_selected):
        ''' Respond to the selection of items in the view. '''
        self.selected = is_selected

class SelectableButton1(RecycleDataViewBehavior, Button):
    ''' Add selection support to the Button '''
    index = None
    selected = BooleanProperty(False)
    selectable = BooleanProperty(True)
    rv_data = ObjectProperty(None)
    start_point = NumericProperty(0)

    def refresh_view_attrs(self, rv, index, data):
        ''' Catch and handle the view changes '''
        self.index = index
        return super(SelectableButton1, self).refresh_view_attrs(rv, index, data)

    def on_touch_down(self, touch):
        ''' Add selection on touch down '''
        if super(SelectableButton1, self).on_touch_down(touch):
            return True
        if self.collide_point(*touch.pos) and self.selectable:
            return self.parent.select_with_touch(self.index, touch)

    def apply_selection(self, rv, index, is_selected):
        ''' Respond to the selection of items in the view. '''
        self.selected = is_selected
        self.rv_data = rv.data

    def on_press(self):
        self.start_point = 0
        end_point = 3
        rows = len(self.rv_data) // 3
        for row in range(rows):
            # check index is in column range
            if self.index in list(range(end_point)):
                break
            self.start_point += 3
            end_point += 3
        popup = RoomInfoUpd(self)
        popup.open()

    def update_changes(self, room_class, room_type, price):
        self.text = price
        q = "exec ChangePrice @room_class = ?, @type = ?, @price_accmd = ?"
        print(room_class, room_type, price)
        cursor.execute(q, (room_class, room_type, float(price)))
        db.commit()


class SelectableButton2(RecycleDataViewBehavior, Button):
    index = None

    def refresh_view_attrs(self, rv, index, data):
        self.index = index
        return super(SelectableButton2, self).refresh_view_attrs(rv, index, data)


class SelectableButton3(RecycleDataViewBehavior, Button):
    index = None
    selected = BooleanProperty(False)
    selectable = BooleanProperty(True)
    rv_data = ObjectProperty(None)
    start_point = NumericProperty(0)

    def refresh_view_attrs(self, rv, index, data):
        self.index = index
        return super(SelectableButton3, self).refresh_view_attrs(rv, index, data)

    def on_touch_down(self, touch):
        if super(SelectableButton3, self).on_touch_down(touch):
            return True
        if self.collide_point(*touch.pos) and self.selectable:
            return self.parent.select_with_touch(self.index, touch)

    def apply_selection(self, rv, index, is_selected):
        self.selected = is_selected
        self.rv_data = rv.data

    def on_press(self):
        self.start_point = 0
        end_point = 4
        rows = len(self.rv_data) // 4
        for row in range(rows):
            if self.index in list(range(end_point)):
                break
            self.start_point += 4
            end_point += 4
        popup = BookingData(self)
        popup.open()

    def update_changes(self, full_name, phone_num, credit_num, check_in, check_out, room_no):

        if full_name and phone_num and credit_num:
            print(full_name, phone_num, credit_num)
            q = """\
                EXEC register_user @FULL_NAME=?, @PHONE_NUM=?, @CITY='-', @CREDIT_NUM=?, @CHECK_IN=?, @CHECK_OUT=?, @PAYMNT_TYPE=?
                """
            cursor.execute(q, full_name, phone_num, credit_num, check_in, check_out, payment_type)
            db.commit()
            q1 = """\
                 DECLARE @rv nvarchar(max);
                 EXEC @rv=booking @ROOM_NUM=?, @GUEST_PHONE_NUM=?;
                 SELECT @rv AS return_value;
                 """
            cursor.execute(q1, int(room_no), phone_num)
            row = cursor.fetchone()
            db.commit()
            txt = row[0]
            print(row)

            q2 = "select convert(date, getdate())"
            cursor.execute(q2)
            row = cursor.fetchone()
            today = row[0]

            q3 = "exec getprice @phon_num = ?"
            cursor.execute(q3, phone_num)
            row = cursor.fetchone()
            price = row[0]
            db.commit()
            reservation_info(check_in, check_out, price, today)
            rsrv_stat(txt)

class EmpDatabase:
    id = 0

    def check(self, login, passswrd):
        q = """
            if exists(select * from EMPLOYEE where LOGIN = ? and PASSWORD = ?)
            begin
	            select 1
            end
            else begin
	            select 0
            end
        """
        cursor.execute(q, login, passswrd)
        row = cursor.fetchone()[0]
        return row

    def get_id(self, login):
        q = "select EMP_ID from EMPLOYEE where LOGIN=?"
        cursor.execute(q, login)
        row = cursor.fetchone()[0]
        self.id = row

class LogInWindow(Screen):
    login = ObjectProperty(None)
    password = ObjectProperty(None)
    login_btn = ObjectProperty(None)

    def emp_operation(self):
        if emp.check(self.login.text, self.password.text):
            emp.get_id(self.login.text)
            EmpFirstWindow.current = emp.id
            self.password.text = ''
            self.login.text = ''
            sm.current = "emp_first"
        else:
            d_pop(3, "User not found")

class EmpFirstWindow(Screen):

    current = 0

    def on_enter(self, *args):
        q = """select substring(emp.FULL_NAME, 1, charindex(' ', emp.FULL_NAME) - 1) as name
               , substring(emp.FULL_NAME, charindex(' ', emp.FULL_NAME) + 1, len(emp.FULL_NAME) - charindex(' ', emp.FULL_NAME)) as surname
               , p.POS_NAME from EMPLOYEE emp
               join POSITION p on p.POS_ID = emp.POS_ID where EMP_ID=?;"""

        cursor.execute(q, self.current)
        row = cursor.fetchone()
        db.commit()
        print(self.current)
        self.ids.curr_id.text = f"ID: {self.current}"
        self.ids.curr_name.text = "Name: " + row[0]
        self.ids.curr_surname.text = "Surname: " + row[1]
        self.ids.curr_pos.text = "Position: " + row[2]

    def to_time(self):
        EmpSixthWindow.current = self.current
        sm.current = "emp_sixth"

    def set_payment_type(self):
        for_booking_payment("c")
        print(payment_type)

# cancel rsrv window
class EmpSecondWindow(Screen):
    def success_stat(self):
        d_pop(0, self.txt)

    rsrvid = ObjectProperty(None)
    txt = StringProperty('')

    def check(self):
        query = "select * from RESERVATION where RSRV_ID = ?"

        try:
            cursor.execute(query, self.rsrvid.text)
            row = cursor.fetchone()
        except pyodbc.Error as err:
            print('\nERROR !!!!! %s' % err)

        db.commit()

        if row:
            q = """\
                DECLARE @rv nvarchar(max);
                EXEC @rv = cancel_rsrv @RSRV_ID=?;
                SELECT @rv AS return_value;
                """
            try:
                cursor.execute(q, self.rsrvid.text)
                row = cursor.fetchone()
                self.txt = str(row[0])
            except pyodbc.Error as err:
                print('\nERROR !!!!! %s' % err)
        else:
            self.txt = "Record not found"
        print(self.txt)
        db.commit()

class EmpThirdWindow(Screen):
    data_items = ListProperty([])

    def __init__(self, **kwargs):
        super(EmpThirdWindow, self).__init__(**kwargs)

    def get_users(self):

        q = "select CLASS_NAME, CLASS_TYPE, PRICE from ROOM_CLASS"
        cursor.execute(q)
        rows = cursor.fetchall()

        for row in rows:
            for col in row:
                self.data_items.append(col)

class EmpFourthWindow(Screen):
    data_items = ListProperty([])

    def __init__(self, **kwargs):
        super(EmpFourthWindow, self).__init__(**kwargs)
        self.get_users()

    def get_users(self):
        q = """\
            SELECT GUEST_ID, RSRV_DATE, CHECK_IN, CHECK_OUT, [STATUS], DISCOUNT_APPLD FROM RESERVATION WHERE [STATUS] = 'active';
            """
        cursor.execute(q)
        rows = cursor.fetchall()

        # create data_items
        for row in rows:
            print(row)
            for col in row:
                self.data_items.append(col)

# finish rsrv window
class EmpFifthWindow(Screen):
    rsrvid = ObjectProperty(None)
    txt = StringProperty()

    def success_stat(self):
        d_pop(1, self.txt)

    def check(self):
        query = "SELECT * from RESERVATION where RSRV_ID = ?"

        try:
            cursor.execute(query, self.rsrvid.text)
            row = cursor.fetchone()
        except pyodbc.Error as err:
            print('\nERROR !!!!! %s' % err)

        if row:
            q = """\
                SET NOCOUNT ON
                DECLARE @rv nvarchar(max);
                EXEC @rv = finish_rsrv @RSRV_ID=?;
                SELECT @rv AS return_value;
                """
            try:
                cursor.execute(q, self.rsrvid.text)
                row = cursor.fetchone()
                if row:
                    print(row[0])
                    self.txt = row[0]
            except pyodbc.Error as err:
                print('\nERROR !!!!! %s' % err)
        else:
            self.txt = "Record not found"
        print(self.txt)
        db.commit()

class EmpSixthWindow(Screen):
    arrv_t = ObjectProperty(None)
    leav_t = ObjectProperty(None)
    txt = StringProperty()
    current = 0

    def on_enter(self, *args):
        q = "select SALARY, BONUS from EMPLOYEE where EMP_ID=?"

        cursor.execute(q, self.current)
        row = cursor.fetchone()
        db.commit()
        print(self.current)
        self.ids.curr_salary.text = f"Salary: {row[0]}tg"
        self.ids.curr_bonus.text = f"Bonus: {row[1]}tg"

    def emp_money(self):
        q = "select SALARY, BONUS from EMPLOYEE where EMP_ID=?"

        cursor.execute(q, self.current)
        row = cursor.fetchone()
        db.commit()
        print(self.current)
        self.ids.curr_salary.text = f"Salary: {row[0]}tg"
        self.ids.curr_bonus.text = f"Bonus: {row[1]}tg"

    def check(self):

        q = """
            SET NOCOUNT ON
            EXEC BonusEmp @emp_id=?, @arrv_t=?, @leav_t=?;
            """
        cursor.execute(q, (self.current, self.arrv_t.text, self.leav_t.text))
        row = cursor.fetchone()
        self.txt = row[0]
        print(self.txt)
        db.commit()

    def status(self):
        d_pop(2, self.txt)


class RoomInfoStRoom(Screen):
    def room_dscrt(self):
        q = "SELECT CLASS_DSCRPT FROM ROOM_CLASS_DSCRPT WHERE CLASS_NAME = 'Standard Room'"
        cursor.execute(q)
        row = cursor.fetchone()
        new_input = ""
        for letter in (row[0]):
            if letter == '.':
                new_input += '.\n'
            else: new_input += letter
        return new_input
    
    def room_types_price(self):
        q = "select CLASS_TYPE, PRICE  from ROOM_CLASS WHERE CLASS_NAME = 'Standard Room'"
        cursor.execute(q)
        columns = [column[0] for column in cursor.description]
        results = [columns] + [row for row in cursor.fetchall()]
        return results
        
    def get_room_types(self):
        results = self.room_types_price()
        return f"{results[1][0]}\n\n{results[2][0]}"

    def get_room_price(self):
        results = self.room_types_price()
        return f"{results[1][1]} tenge\n\n{results[2][1]} tenge"

class RoomInfoJSRoom(Screen):
    def room_dscrt(self):
        q = "SELECT CLASS_DSCRPT FROM ROOM_CLASS_DSCRPT WHERE CLASS_NAME = 'Junior Suite'"

        cursor.execute(q)
        row = cursor.fetchone()
        new_input = ""
        for letter in (row[0]):
            if letter == '.':
                new_input += '.\n'
            else: new_input += letter
        return new_input
    
    def room_types_price(self):
        q = "select CLASS_TYPE, PRICE  from ROOM_CLASS WHERE CLASS_NAME = 'Junior Suite'"
        cursor.execute(q)
        columns = [column[0] for column in cursor.description]
        results = [columns] + [row for row in cursor.fetchall()]
        return results
        
    def get_room_types(self):
        results = self.room_types_price()

        return f"{results[1][0]}\n\n{results[2][0]}\n\n{results[3][0]}"

    def get_room_price(self):
        results = self.room_types_price()

        return f"{results[1][1]} tenge\n\n{results[2][1]} tenge\n\n{results[3][1]} tenge"

class RoomInfoKSRoom(Screen):
    def room_dscrt(self):
        q = "SELECT CLASS_DSCRPT FROM ROOM_CLASS_DSCRPT WHERE CLASS_NAME = 'King Suite'"

        cursor.execute(q)
        row = cursor.fetchone()
        new_input = ""
        for letter in (row[0]):
            if letter == '.':
                new_input += '.\n'
            else: new_input += letter
        return new_input
    
    def room_types_price(self):
        q = "select CLASS_TYPE, PRICE  from ROOM_CLASS WHERE CLASS_NAME = 'King Suite'"
        cursor.execute(q)
        columns = [column[0] for column in cursor.description]
        results = [columns] + [row for row in cursor.fetchall()]
        return results
        
    def get_room_types(self):
        results = self.room_types_price()
        return f"{results[1][0]}\n\n{results[2][0]}\n\n{results[3][0]}"

    def get_room_price(self):
        results = self.room_types_price()
        return f"{results[1][1]} tenge\n\n{results[2][1]} tenge\n\n{results[3][1]} tenge"

class RoomInfoQSRoom(Screen):
    def room_dscrt(self):
        q = "SELECT CLASS_DSCRPT FROM ROOM_CLASS_DSCRPT WHERE CLASS_NAME = 'Queen Suite'"
        cursor.execute(q)
        row = cursor.fetchone()
        new_input = ""
        for letter in (row[0]):
            if letter == '.':
                new_input += '.\n'
            else: new_input += letter
        return new_input
    
    def room_types_price(self):
        q = "select CLASS_TYPE, PRICE  from ROOM_CLASS WHERE CLASS_NAME = 'Queen Suite'"
        cursor.execute(q)
        columns = [column[0] for column in cursor.description]
        results = [columns] + [row for row in cursor.fetchall()]
        return results
        
    def get_room_types(self):
        results = self.room_types_price()

        return f"{results[1][0]}\n\n{results[2][0]}\n\n{results[3][0]}"

    def get_room_price(self):
        results = self.room_types_price()

        return f"{results[1][1]} tenge\n\n{results[2][1]} tenge\n\n{results[3][1]} tenge"

class RoomInfoSSRoom(Screen):
    def room_dscrt(self):
        q = "SELECT CLASS_DSCRPT FROM ROOM_CLASS_DSCRPT WHERE CLASS_NAME = 'Superior Room'"
        cursor.execute(q)
        row = cursor.fetchone()
        new_input = ""
        for letter in (row[0]):
            if letter == '.':
                new_input += '.\n'
            else: new_input += letter
        return new_input
    
    def room_types_price(self):
        q = "select CLASS_TYPE, PRICE  from ROOM_CLASS WHERE CLASS_NAME = 'Superior Room'"
        cursor.execute(q)
        columns = [column[0] for column in cursor.description]
        results = [columns] + [row for row in cursor.fetchall()]
        return results
        
    def get_room_types(self):
        results = self.room_types_price()
        return f"{results[1][0]}\n\n{results[2][0]}"

    def get_room_price(self):
        results = self.room_types_price()
        return f"{results[1][1]} tenge\n\n{results[2][1]} tenge"

class BookingWindowEmp(Screen):
    check_in = ObjectProperty(None)
    check_out = ObjectProperty(None)
    data_items = ListProperty([])

    def __init__(self, **kwargs):
        super(BookingWindowEmp, self).__init__(**kwargs)

    def get_users(self):
        q = """\
                DECLARE @rv nvarchar(max);
                EXEC @rv=display_active_rooms;
                SELECT @rv AS return_value;
                """
        cursor.execute(q)
        rows = cursor.fetchall()

        # create data_items
        for row in rows:
            for col in row:
                self.data_items.append(col)

    def booking(self):
        # # #
        # нужно добавить проверку формата(yy-mm-dd)
        if self.check_in.text and self.check_out.text:
            self.get_users()

class BookingWindowGuest(Screen):
    check_in = ObjectProperty(None)
    check_out = ObjectProperty(None)
    data_items = ListProperty([])

    def __init__(self, **kwargs):
        super(BookingWindowGuest, self).__init__(**kwargs)

    def get_users(self):
        q = """\
                DECLARE @rv nvarchar(max);
                EXEC @rv=display_active_rooms;
                SELECT @rv AS return_value;
                """
        cursor.execute(q)
        rows = cursor.fetchall()

        # create data_items
        for row in rows:
            for col in row:
                self.data_items.append(col)

    def booking(self):
        # # #
        # нужно добавить проверку формата(yy-mm-dd)
        if self.check_in.text and self.check_out.text:
            self.get_users()

class MyLayout(Screen):

    def set_payment_type(self):
        for_booking_payment("o")
        print(payment_type)

class WindowManager(ScreenManager):
    pass


def reservation_info(check_in, check_out, price, today):
    with open("rsrv_info.txt", "w") as file:
        file.write("*"*20 + "\n" + "RESERVATION BILL" + "\n" + "*"*20)
        file.write("\n\n")
        file.write("CHECK IN: " + check_in + "   \n")
        file.write("CHECK OUT: " + check_out + "   \n")
        file.write("TOTAL PRICE: " + str(price) + "   \n")

        file.write("*" * 20)
        file.write("\n\n")
        file.write("PAYMENT TYPE: " + payment_type + "   \n")
        file.write("DATE: " + str(today) + "   \n")


def save_file():
    # will be change
    save_path = '/Users/macbookair/Downloads/'
    # # #
    completeName = os.path.join(save_path, "reserv_info.txt")

    with open("rsrv_info.txt") as f:
        lines = f.readlines()
        print(lines)
        with open(completeName, "w") as f1:
            f1.writelines(lines)

def for_booking_payment(tp):
    global payment_type
    if tp == 'o':
        payment_type = "online"
    elif tp == 'c':
        payment_type = "by cash"


Builder.load_file("hotel.kv")

emp = EmpDatabase()
sm = WindowManager()
screens = [LogInWindow(name="login"), EmpFirstWindow(name="emp_first"), EmpSecondWindow(name="emp_second"), EmpThirdWindow(name="emp_third"),
            EmpFourthWindow(name="emp_fourth"), EmpFifthWindow(name="emp_fifth"), EmpSixthWindow(name="emp_sixth"),
            BookingWindowEmp(name="booking-emp"), BookingWindowGuest(name="booking-guest"), MyLayout(name="main-page"), RoomInfoStRoom(name="standard-room"), RoomInfoJSRoom(name="junior-suite"),
            RoomInfoKSRoom(name="king-suite"), RoomInfoQSRoom(name="queen-suite"), RoomInfoSSRoom(name="superior-suite") ]
for screen in screens:
    sm.add_widget(screen)

sm.current = "main-page"
payment_type = ""

class MainApp(App):

    def build(self):
        Window.clearcolor = (1, 1, 1, 1)
        return sm


def d_pop(pp_num, message):
    saved = [["Request Status", 520, 270], ["Request Status", 400, 270],
             ["Status", 430, 200], ["Status", 430, 200]]
    bx = BoxLayout(orientation='vertical', padding=10)
    bx.add_widget(Label(text=message))
    btn1 = Button(text="Close")
    bx.add_widget(btn1)

    popup = Popup(title=saved[pp_num][0], title_size=(20), title_align="center", content=bx, auto_dismiss=False,
                  size_hint=(None, None), size=(saved[pp_num][1], saved[pp_num][2]))
    btn1.bind(on_press=popup.dismiss)
    popup.open()

def rsrv_stat(message):
    bx = BoxLayout(orientation='vertical', padding=20, spacing = 20)
    bx.add_widget(Label(text=message))
    btn1 = Button(text="Download")
    bx.add_widget(btn1)

    popup = Popup(title="Status", title_align="center", content=bx, size_hint=(None, None), size=(400, 250))
    btn1.bind(on_press=lambda x:save_file())
    
    popup.open()

if __name__ == '__main__':
    MainApp().run()