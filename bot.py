import telebot
import yaml
from glossary import gls
import requests
from rich import print
from rich.console import Console
from datetime import datetime
from dotenv import load_dotenv
import os


# CONSTANTS
load_dotenv()

TOKEN = os.environ.get("TOKEN")
ADMIN = os.environ.get("ADMIN")

# GLOBALS
console = Console()

# FUNCTIONS
def _handler(bot):
    @bot.message_handler(content_types=['text'])
    def send_text(message):
        console.log(f'Allowed: {message.chat.id} -> {check_banned(message)}')
        if check_banned(message) == True:
            pick_cmd(bot, message)

        else:
            _cnf(bot, message)

def pick_cmd(bot, message):
    console.log(message.text.lower())
    if message.text.lower() in gls:
        try:
            data = gls[message.text.lower()]()

            bot.send_message(
                message.chat.id,
                data
            )
            logs(message)

        except Exception as ex:
            logs(message , ex)
            bot.send_message(
                message.chat.id,
                f'{ex}'
            )
    else:
        _cnf(bot, message)

def _cnf(bot, message) -> None:
    cnf = f"CNF: {message.text.lower()}"
    logs(message, cnf)
    bot.send_message(
        message.chat.id,
        cnf
    )

def logs(msg: object, ex = 'None'):
    data = {
        msg.date: {
            'ID': msg.from_user.id,
            'User Details': msg.from_user,
            'Message': msg.text,
            'Exeption': ex
        }
    }
    try:
        with open('logs.yml','a') as file:
            _extracted_from_logs_12(file, data)
    except Exception as ex:
        with open('logs.yml', 'w') as file:
            _extracted_from_logs_12(file, data)

# TODO Rename this here and in `logs`
def _extracted_from_logs_12(file, data):
    console = Console(file=file)
    console.rule(f"Report Generated {datetime.now().ctime()}")
    yaml.dump(data, file, default_flow_style=False)

def ban_user(msg: object):
    data = {
            msg.date: {
                'ID': msg.from_user.id
            }
        }
    try:
        with open('banned.yml','a') as file:
            _extracted_from_logs_12(file, data)

    except Exception as ex:
        with open('banned.yml','w') as file:
            _extracted_from_logs_12(file, data)

def check_banned(msg) -> bool:
    try:
       with open('banned.yml') as file:
            data = yaml.load(file, Loader=yaml.Loader)
            for k, v in data.items():
                for x in v.keys():
                    if int(v[x]) == int(msg.from_user.id):
                        return False
            return True
    except Exception as ex:
        # TODO WARNING!!!!!! AHTUNG!!!!
        return True

def telegram_bot(api_token):
    bot = telebot.TeleBot(api_token)

    @bot.message_handler(commands=['start'])
    def start_msg(message):
        if message.chat.id == int(ADMIN):
            bot.send_message(message.chat.id, f"Hello {message.from_user.first_name}!")
            console.log(f'Loggen in: {message.from_user.first_name, message.chat.id}')

        else:
            bot.send_message(message.chat.id, "403")
            console.log(f'Tried: {message.from_user.first_name, message.chat.id}')
            ban_user(message)

        logs(message)

    _handler(bot)
    bot.polling()
    # TODO when in prod uncomment
    # while True:
    #     try:
    #         console.log("[bold magenta]Started[/bold magenta]")
    #         bot.polling()
    #     except requests.exceptions.ReadTimeout:
    #         console.log("[bold magenta]Reloaded[/bold magenta]")
    #         continue


if __name__ == '__main__':
    telegram_bot(TOKEN)
