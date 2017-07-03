class Asciinema.WorkerProxy
  constructor: (url) ->
    @webWorker = new window.Worker(url)
    @webWorker.addEventListener 'message', @onMessage

  init: (options) ->
    @webWorker.postMessage
      message: 'init'
      options: options

  getObjectProxy: (objectName) ->
    new Asciinema.WorkerObjectProxy(@webWorker, objectName)

  onMessage: (e) =>
    if e.data.message == 'log'
      console.log e.data.text
