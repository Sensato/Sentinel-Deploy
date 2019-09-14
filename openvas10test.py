import logging
import sys
import json
from time import sleep
from gvm.connections import UnixSocketConnection
from gvm.errors import GvmError
from gvm.protocols.latest import Gmp
from gvm.protocols.gmpv8 import AliveTest
from gvm.transforms import EtreeTransform
from gvm.xml import pretty_print
from random import randint
from uuid import uuid4


class OpenvasRemote:
    def __init__(self, path, connection, transform):
        self.path = path
        self.connection = connection
        self.gmp = Gmp(connection=connection, transform=transform)
        
    def create_task(self, task_name, config_id, target_id, scanner_id, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.create_task(
                    task_name, config_id, target_id, scanner_id)
                pretty_print(response)
                id = response.xpath('@id')
                return id[0]
        except GvmError as e:
            print(e)
            return 'bad'

    def create_target(self, target_name, targets_list, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.create_target(
                    target_name, hosts=targets_list,alive_test=AliveTest.CONSIDER_ALIVE)
                pretty_print(response)
                if(response.xpath("@status_text")[0] == 'Target exists already'):
                    with self.gmp:
                        self.gmp.authenticate(username, password)
                        response = self.gmp.get_targets(
                            filter="name={0}".format(target_name))
                        target_id = response.xpath('target/@id')[0]
                        return target_id
                else:
                    id = response.xpath('@id')[0]
                    return id
        except GvmError as e:
            print(e)
            return 'bad'

    #this also delete all the reports
    def delete_all_tasks(self, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.get_tasks()
                for task in response.xpath('task'):
                    task_id = task.xpath('@id')[0]
                    response = self.gmp.delete_task(task_id)
                    pretty_print(response)
                result = {'status': 'good'}
                return result
        except GvmError as e:
            print(e)
            result = {'status': 'bad'}
            return result

    def delete_all_targets(self, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.get_targets()
                for target in response.xpath('target'):
                    target_id = target.xpath('@id')[0]
                    response = self.gmp.delete_target(target_id)
                    pretty_print(response)
                result = {'status': 'good'}
                return result
        except GvmError as e:
            print(e)
            result = {'status': 'bad'}
            return result

    @staticmethod
    def get_full_and_fast_config_id():
        return 'daba56c8-73ec-11df-a475-002264764cea'

    @staticmethod
    def get_default_openvas_scanner_id():
        return '08b69003-5fc2-4037-a479-93b440211c73'

    def get_report(self, id, target_list, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.get_report(id)
                running_status = response.xpath(
                    'report/report/scan_run_status/text()')[0]
                if(running_status == 'Done'):
                    print(response.xpath('report/@id')[0])
                    report = {}
                    hosts = []
                    for IP_address in target_list:
                        host = {}
                        host['ip_address'] = IP_address
                        host['results'] = []
                        host['results_count'] = 0
                        hosts.append(host)

                    for report_result in response.xpath('report/report/results/result'):
                        print(
                            '=======================================================================')
                        result = {}
                        result['report_id'] = report_result.xpath('@id')[0]
                        result['description'] = report_result.xpath(
                            'description/text()')[0]
                        result['name'] = report_result.xpath('name/text()')[0]
                        result['port'] = report_result.xpath('port/text()')[0]
                        result['nvt_bid'] = report_result.xpath(
                            'nvt/bid/text()')[0]
                        result['nvt_cve'] = report_result.xpath(
                            'nvt/cve/text()')[0]
                        result['nvt_cvss_base'] = report_result.xpath(
                            'nvt/cvss_base/text()')[0]
                        result['nvt_family'] = report_result.xpath(
                            'nvt/family/text()')[0]
                        result['nvt_oid'] = report_result.xpath('nvt/@oid')[0]
                        result['nvt_tags'] = report_result.xpath(
                            'nvt/tags/text()')[0]
                        result['nvt_type'] = report_result.xpath(
                            'nvt/type/text()')[0]
                        result['nvt_xref'] = report_result.xpath(
                            'nvt/xref/text()')[0]
                        result['quality_of_detection_value'] = report_result.xpath(
                            'qod/value/text()')[0]
                        result['quality_of_detection_type'] = report_result.xpath(
                            'qod/type/text()')[0]
                        result['threat'] = report_result.xpath(
                            'threat/text()')[0]
                        result['severity'] = report_result.xpath(
                            'severity/text()')[0]
                        for host in hosts:
                            if(host['ip_address'] == report_result.xpath('host/text()')[0]):
                                host['results'].append(result)
                    report['hosts'] = hosts
                    report['ip_address_count'] = len(target_list)
                    report['status'] = 'received'
                    
                    print(json.dumps(report))
                    return report
                else:
                    report = {'status': 'running'}
                    return report
        except GvmError as e:
            no_report = {'status': 'bad'}
            print(e)
            return no_report

    def get_reports(self, id, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.get_reports()
                pretty_print(response)
        except GvmError as e:
            print(e)

    def get_full_report(self, id, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.get_report(id)
                pretty_print(response)
        except GvmError as e:
            print(e)

    def get_targets(self, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.get_targets()
                pretty_print(response)
                for target in response.xpath('target'):
                    pretty_print(target.xpath('@id'))
        except GvmError as e:
            print(e)

    def get_task(self, id, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                reponse = self.gmp.get_task(id)
                pretty_print(reponse)
        except GvmError as e:
            print(e)

    def get_tasks(self, username, password):
        try:
            with self.gmp:
                self.gmp.authenticate(username, password)
                response = self.gmp.get_tasks()
                for task in response.xpath('task'):
                    pretty_print(task.xpath('@id'))
        except GvmError as e:
            print(e)

    def scan_target(self, task_name, target_name, targets_list, username, password):
        try:
            target_id = self.create_target(
                target_name, targets_list, username, password)
            if(target_id == 'bad'):
                return ('bad','bad','bad','bad')
            task_id = self.create_task(task_name, self.get_full_and_fast_config_id(), target_id,
                self.get_default_openvas_scanner_id(), username, password)
            if(task_id == 'bad'):
                return ('bad','bad','bad','bad')
            task_tuple = self.start_task(task_id, username, password)
            if(task_tuple[0] =='bad'):
                return ('bad','bad','bad','bad')
            report_id = task_tuple[0]
            status = task_tuple[1]
            return (target_id,task_id,report_id, status)
        except GvmError as e:
            print(e)
            return ('bad','bad','bad','bad')

    def start_task(self, id, username, password):
        try:
            with self.gmp:
                print(id)
                self.gmp.authenticate(username, password)
                reponse = self.gmp.start_task(id)
                report_id = reponse.xpath('report_id/text()')
                status = 'start'
                if(len(report_id) == 0):
                    return ('bad','bad')
                return (report_id[0], status)
        except GvmError as e:
            print(e)
            return ('bad', 'bad')
    def test1(self, task_name, target_name,ip_address_list,ip_address_count_per_report,username,password):
        
        run_task_name = task_name + '_' + str(uuid4())
        total_ip_addresses = len(ip_address_list)
        remainder = total_ip_addresses % ip_address_count_per_report
        chopped_ip_addresses = total_ip_addresses - remainder
        count = 0
        left_index = 0
        right_index = ip_address_count_per_report
        for batch in range(chopped_ip_addresses//ip_address_count_per_report):
            slice_object = slice(left_index,right_index)
            sub_ip_address_list = ip_address_list[slice_object]
            left_index = left_index + ip_address_count_per_report
            right_index = right_index + ip_address_count_per_report
            run_task_name_id = run_task_name + '_batch_number_' + str(batch)
            run_target_name_id = run_task_name_id + '_target_' + target_name
            count = count + 1
            report_tuple = self.scan_target(run_task_name_id,run_target_name_id, sub_ip_address_list, username, password)
        if( remainder > 0):
            slice_object = slice(-remainder,total_ip_addresses)
            sub_ip_address_list = ip_address_list[slice_object]
            run_task_name_id = run_task_name + '_batch_number_' + str(count)
            run_target_name_id = run_task_name_id + '_target_' + target_name
            report_tuple = self.scan_target(run_task_name_id,run_target_name_id, sub_ip_address_list, username, password)

def main():
    logging.basicConfig(filename='openvas-error.log', level=logging.ERROR)
    logging.basicConfig(filename='openvas-debug.log', level=logging.DEBUG)
    path = '/usr/local/var/run/gvmd.sock'
    connection = UnixSocketConnection(path=path)
    transform = EtreeTransform()
    openvas_remote = OpenvasRemote(path, connection, transform)
    username = "".join(sys.arg[1])
    password = "".join(sys.arg[2])
    #==================Comment the next 4 line with after running this python script===================================
    id = openvas_remote.create_target('Raybox',['192.168.112.137'], username, password)
    task_id = openvas_remote.create_task('OpenVasTestBox',  openvas_remote.get_full_and_fast_config_id(), id,  openvas_remote.get_default_openvas_scanner_id(), username , password)
    report_id = openvas_remote.start_task(task_id, username, password)
    print('replace this id: ' + report_id + ' in report id in this code file to get the report in a json format')
    #==================Ucomment next line after running this python script once==================
    #openvas_remote.get_report('report_id',['192.168.112.137'], username,password)

if __name__ == "__main__":
    main()
