
class GenericData:

    def __init__(self, data_id: str):

        self.data_id = data_id
        self.data = None
        self.reset_data()
        self.get_data()

    def reset_data(self):

        self.data = []

    def get_data(self):

        pass

