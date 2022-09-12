class PersistentVolumeIterable(object):
    def __init__(self, k8s_client, **kwargs):
        self.k8s_client = k8s_client
        self.kwargs = kwargs

    def __iter__(self):
        return PersistentVolumeIterator(self.k8s_client, **self.kwargs)


class PersistentVolumeIterator(object):
    def __init__(self, k8s_client, **kwargs):
        self.k8s_client = k8s_client
        self.kwargs = kwargs
        self.page = None
        self._continue = None
        self.page_ix = 0

    def __next__(self):
        if self.page is None:
            if self._continue is not None:
                self.kwargs['_continue'] = self._continue
            elif '_continue' in self.kwargs:
                self.kwargs.pop('_continue')
            self.page = self.k8s_client.list_persistent_volume(**self.kwargs)
            self.page_ix = 0

        if self.page_ix < len(self.page.items):
            result = self.page.items[self.page_ix]
            self.page_ix += 1
            if (self.page_ix == len(self.page.items) and
                    self.page.metadata._continue is not None and
                    self.page.metadata._continue != ''):
                self._continue = self.page.metadata._continue
                self.page = None
            return result
        else:
            self.page = None
            self._continue = None
            raise StopIteration
