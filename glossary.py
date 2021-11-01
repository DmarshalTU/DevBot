import sh
from datetime import datetime


current_year_full = datetime.now().strftime('%Y')
current_month = datetime.now().strftime('%m')
current_day = datetime.now().strftime('%d')


def testr():
    return str(sh.aws("--version"))

def cost():
    return str(sh.aws('ce',
                'get-cost-and-usage',
                '--time-period', f'Start={current_year_full}-{current_month}-01,End={current_year_full}-{current_month}-{current_day}',
                '--granularity', 'MONTHLY',
                '--metrics', 'BlendedCost'))

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

gls  = {
    'testr': testr,
    'cost': cost,
    'ls-usr': ls_usr,
    'tr': tree
}
