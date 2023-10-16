import unittest
import logging
from src import ConnectorFactory, StrategyManager
import os
from datetime import datetime


class StrategyManager_TestCase(unittest.TestCase):

  logger = logging.getLogger(__name__)
  logging.basicConfig(format='%(asctime)s %(module)s %(levelname)s: %(message)s',
                      datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
  conn_f = ConnectorFactory(dbname=os.environ.get("DB_NAME_TEST"), host=os.environ.get("DB_HOST_TEST"),
                            password=os.environ.get("TU_PWD_TEST"), user=os.environ.get("TU_USER_TEST"))

  def test_WHEN_post_new_strategy_THEN_create_strategy_row_and_version_row(self):
    # Array
    ts = datetime.now().timestamp()
    expected_str_name = "StrategyManager"+str(ts)
    expected_str_description = "test_WHEN_post_new_strategy_THEN_create_strategy_row_and_version_row"
    str_m = StrategyManager(self.conn_f, self.logger)

    # Act
    new_str_id = str_m.PostStrategy(
        expected_str_name, "test_WHEN_post_new_strategy_THEN_create_strategy_row_and_version_row",)

    # Assert
    asserted_str = str_m.GetStrategyById(new_str_id)

    self.assertEqual(asserted_str.name, new_str_id)
    self.assertEqual(asserted_str["name"], expected_str_name)
    self.assertEqual(asserted_str["description"],  expected_str_description)
