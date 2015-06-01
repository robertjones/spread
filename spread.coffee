load = (numNodes) ->

  d3.select('svg').remove()
  d3.select('p').remove()

  width = 960
  height = 500

  force = d3.layout.force()
            .charge(-300)
            .linkDistance(65)
            .size([width, height])
            .gravity(0.2)
            .linkStrength(0.2)

  svg = d3.select('body').append('svg')
          .attr('width', width)
          .attr('height', height)

  d3.select('body').append('p').attr('class', 'small')
    .html("""By <a href="http://www.twitter.com/robjones">Rob Jones</a>.
             <a href="https://github.com/robertjones/spread">View code</a>.""")

  msgBox = svg.append('text')
              .attr('x', 5)
              .attr('y', 25)
              .text('Click to immunise')

  showButton = ->
    buttonGroup1 = svg.append('g')
    buttonGroup1.append('rect').attr('width', 100).attr('height', 30)
                .attr('fill', 'blue').attr('x', 5).attr('y', 5 + 40)
    buttonGroup1.append('text').text('Play again').attr('fill', 'white')
                .attr('font-weight', 'bold').attr('x', 15).attr('y', 25 + 40)
    buttonGroup1.on('click', -> load(numNodes))

    buttonGroup2 = svg.append('g')
    buttonGroup2.append('rect').attr('width', 100).attr('height', 30)
                .attr('fill', 'blue').attr('x', 100 + 10 + 5).attr('y', 5 + 40)
    buttonGroup2.append('text').text('Next level').attr('fill', 'white')
                .attr('font-weight', 'bold')
                .attr('x', 100 + 10 + 15).attr('y', 25 + 40)
    buttonGroup2.on('click', -> load(numNodes+10))

  keyData = ['infected', 'healthy', 'immune']

  svg.selectAll('.key').data(keyData).enter()
     .append('circle')
     .attr('class', (d) -> d)
     .attr('r', 8)
     .attr('cx', width - 85)
     .attr('cy', (d,i) -> (i+1) * 25)

  svg.selectAll('.keyText').data(keyData).enter()
     .append('text')
     .text((d) -> d)
     .attr('x', width - 85 + 15)
     .attr('y', (d,i) -> (i+1) * 25 + 5)

  svg.append('rect')
     .attr('fill', 'transparent')
     .attr('stroke', '#ccc')
     .attr('stroke-width', 1)
     .attr('x', width - 85 - 15)
     .attr('y', 7)
     .attr('width', 95)
     .attr('height', keyData.length * 25 + 10)

  gameOver = ->
    numInfected = _.filter(graph.nodes, {'status': 'infected'}).length
    numSafe = graph.nodes.length - numInfected
    msgBox.text("Game over. Infected: #{numInfected}, safe: #{numSafe}")
    showButton()

  generateGraph = (numNodes) ->
    numInfected = parseInt(numNodes**0.85/10+1.5)
    states = _.shuffle(_.times(numInfected, -> 'infected')
                       .concat(_.times(numNodes - numInfected, -> 'healthy')))
    "nodes": ({"status": state} for state in states)
    "links": _.flatten _.times parseInt(numNodes*1.2), ->
      a = _.random(numNodes-1)
      b = _.random(numNodes-1)
      [{"source": a,"target": b}, {"source": b,"target": a}]

  graph = generateGraph(numNodes)

  infect = ->
    _(graph.links).filter({'source': {'status': 'infected'}})
                  .filter({'target': {'status': 'healthy'}})
                  .each((link) ->
                    link.target.status = 'infected' if _.random(1))
                  .value()
    possInfectees = _(graph.links).filter({'source': {'status': 'infected'}})
                                  .filter({'target': {'status': 'healthy'}})
                                  .value()
                                  .length
    gameOver() if possInfectees == 0
    force.resume()

  force.nodes(graph.nodes).links(graph.links).start()

  # Enter and update links
  link = svg.selectAll('.link').data(graph.links).enter()
          .append('line')
          .attr('class', 'link')

  # Enter nodes
  node = svg.selectAll('.node').data(graph.nodes).enter()
          .append('circle')
          .attr('class', (d) -> d.status)
          .attr('r', 15)
          .call(force.drag)
          .on('click', (d) ->
            if d.status == 'healthy'
              d.status = 'immune'
              infect())

  # Update attributes
  force.on 'tick', ->
    link.attr('x1', (d) -> d.source.x)
        .attr('y1', (d) -> d.source.y)
        .attr('x2', (d) -> d.target.x)
        .attr('y2', (d) -> d.target.y)
    node.attr('cx', (d) -> d.x)
        .attr('cy', (d) -> d.y)
        .attr('class', (d) -> d.status)

load(20)
