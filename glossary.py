import sh
from datetime import datetime
from rich.console import Console
import re
import json


console = Console()


current_year_full = datetime.now().strftime('%Y')
current_month = datetime.now().strftime('%m')
current_day = datetime.now().strftime('%d')


def escape_ansi(line):
    ansi_escape = re.compile(r'(?:\x1B[@-_]|[\x80-\x9F])[0-?]*[ -/]*[@-~]')
    return ansi_escape.sub('', line)

def testr():
    return str(sh.aws("--version"))

def cost():
    plan = str(sh.aws('ce',
                'get-cost-and-usage',
                '--time-period', f'Start={current_year_full}-{int(current_month) - 1}-01,End={current_year_full}-{current_month}-{current_day}',
                '--granularity', 'MONTHLY',
                '--metrics', 'BlendedCost'))
    json_data = json.loads(plan)
    a = json_data["ResultsByTime"][0]["Total"]["BlendedCost"]["Amount"]

    return "%.2f$" % round(float(a), 2)

def ls_usr():
    return str(sh.aws('iam', 'list-users'))

def tree():
    return str(sh.tree())

def crt_vpc():
    return str(sh.aws('ec2',\
                        'create-vpc',\
                        '--cidr-block',\
                        '10.0.0.0/16',\
                        '--query',\
                        'Vpc.VpcId',\
                        '--output',\
                        'text'
                ))

def scn1p():
    dir = sh.cd('SCN1/terraform')
    sh.terraform("init", dir)
    try:
        plan = str(sh.grep(sh.terraform("plan", dir), "Plan:"))
        console.log(escape_ansi(plan))
        return escape_ansi(plan)
    except Exception as ex:
        print(ex)
        return escape_ansi(ex)
    finally:
        sh.cd("..")
        sh.cd("..")


def scn1a():
    dir = sh.cd('SCN1/terraform')
    sh.terraform("init", dir)
    try:
        plan = str(sh.grep(sh.terraform("apply", "-auto-approve", dir), "public_ip = "))
        console.log(escape_ansi(plan))
        return escape_ansi(plan)
    except Exception as ex:
        console.log(ex)
        return escape_ansi(ex)
    finally:
        sh.cd("..")
        sh.cd("..")


def scn1d():
    dir = sh.cd('SCN1/terraform')
    sh.terraform("init", dir)
    try:
        plan = str(sh.grep(sh.terraform("apply", "-destroy", "-auto-approve", dir), "Apply complete!"))
        console.log(escape_ansi(plan))
        return escape_ansi(plan)
    except Exception as ex:
        return escape_ansi(ex)
    finally:
        sh.cd("..")
        sh.cd("..")


gls  = {
    'testr': testr,
    'cost': cost,
    'ls-usr': ls_usr,
    'tr': tree,
    'crt-vpc': crt_vpc,
    'scn1 p': scn1p,
    'scn1 a': scn1a,
    'scn1 d': scn1d
}
