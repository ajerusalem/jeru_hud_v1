const arcX = 45
const arcY = 45
const arcRadius = 40

document.querySelector('#speed-background path').setAttribute(
    'd',
    describeArc([arcX, arcY], arcRadius, -210, 0)
)

document.querySelector('#speed path').setAttribute(
    'd',
    describeArc([arcX, arcY], arcRadius, -210, -210 + 1 * 2.1)
)

function polarToCartesian(center, radius, angleInDegrees) {
    const angleInRadians = angleInDegrees * Math.PI / 180.0
    return [
        center[0] + radius * Math.cos(angleInRadians),
        center[1] + radius * Math.sin(angleInRadians)
    ]
}

function describeArc(center, radius, startAngle, endAngle) {
    const start = polarToCartesian(center, radius, startAngle)
    const end = polarToCartesian(center, radius, endAngle)
    const largeArcFlag = endAngle - startAngle <= 180 ? '0' : '1';
    d = [
        'M', start[0], start[1],
        'A', radius, radius, 0, largeArcFlag, 1, end[0], end[1]
    ]
    return d.join(' ')
}

window.addEventListener('message', (event) => {
    if (event.data.action === 'open') {
        change(document.querySelector('#container'), 'opacity', 1)
    }
    if (event.data.action === 'close') {
        change(document.querySelector('#container'), 'opacity', 0)
    }

    if (event.data.passenger) {
        change(document.querySelector('.driver'), 'opacity', 0)
        change(document.querySelector('.passenger'), 'opacity', 1)
    } else if (event.data.passenger === false) {
        change(document.querySelector('.driver'), 'opacity', 1)
        change(document.querySelector('.passenger'), 'opacity', 0)
    }

    if (event.data.doors === 2 || event.data.doors === 3) {
        change(document.querySelector('.passenger .doors'), 'removeClass', 'hide')
    } else if (event.data.doors === 0 || event.data.doors === 1) {
        change(document.querySelector('.passenger .doors'), 'addClass', 'hide')
    }
    if (event.data.seatbelt) {
        change(document.querySelector('.passenger .seatbelt'), 'removeClass', 'hide')
    } else if (event.data.seatbelt === false) {
        change(document.querySelector('.passenger .seatbelt'), 'addClass', 'hide')
    }

    if (event.data.speed) {
        document.querySelector('#speed-text span').innerText = Math.floor(event.data.speed * 3.6)
        var percent = event.data.speed * 100 / event.data.maxSpeed
        if (percent > 100) percent = 100
        document.querySelector('#speed path').setAttribute(
            'd',
            describeArc([arcX, arcY], arcRadius, -210, -210 + percent * 2.1)
        )
    }

    if (event.data.fuel) {
        const fuel = event.data.fuel
        const height = 24 * fuel / 100
        const margin = 24 - height
        if (event.data.fuel <= 0) {
            change(document.querySelector('.fuel-display'), 'removeClass', 'blink')
            change(document.querySelector('#fuel-off'), 'opacity', 1)
            change(document.querySelector('#fuel-alert'), 'opacity', 0)
            change(document.querySelector('#fuel-background'), 'opacity', 0)
        } else if (event.data.fuel > 0 && event.data.fuel <= 14.6484) {
            change(document.querySelector('.fuel-display'), 'addClass', 'blink')
            change(document.querySelector('#fuel-off'), 'opacity', 0)
            change(document.querySelector('#fuel-remaining'), 'height', height +'px')
            change(document.querySelector('#fuel-remaining'), 'margin-top', margin +'px')
            change(document.querySelector('#fuel-alert'), 'opacity', 1)
            change(document.querySelector('#fuel-background'), 'opacity', 1)
        } else if (event.data.fuel > 14.6484) {
            change(document.querySelector('.fuel-display'), 'removeClass', 'blink')
            change(document.querySelector('#fuel-off'), 'opacity', 0)
            change(document.querySelector('#fuel-remaining'), 'height', height +'px')
            change(document.querySelector('#fuel-remaining'), 'margin-top', margin +'px')
            change(document.querySelector('#fuel-alert'), 'opacity', 1)
            change(document.querySelector('#fuel-background'), 'opacity', 1)
        }
    }

    if (event.data.maxFuel !== undefined) {
        if (event.data.maxFuel > 0) {
            change(document.querySelector('#fuel-electric'), 'opacity', 0)
            change(document.querySelector('#fuel-alert'), 'opacity', 1)
        } else {
            change(document.querySelector('.fuel-display'), 'removeClass', 'blink')
            change(document.querySelector('#fuel-electric'), 'opacity', 1)
            change(document.querySelector('#fuel-alert'), 'opacity', 0)
            change(document.querySelector('#fuel-off'), 'opacity', 0)
            change(document.querySelector('#fuel-background'), 'opacity', 0)
        }
    }

    if (event.data.tires) {
        change(document.querySelector('#tires'), 'removeClass', 'hide')
    } else if (event.data.tires === false) {
        change(document.querySelector('#tires'), 'addClass', 'hide')
    }

    if (event.data.blinkers === 1) {
        change(document.querySelector('#blinker-left'), 'removeClass', 'hide')
        change(document.querySelector('#blinker-right'), 'addClass', 'hide')
        change(document.querySelector('#blinker-left'), 'addClass', 'blink')
        change(document.querySelector('#blinker-right'), 'removeClass', 'blink')
    } else if (event.data.blinkers === 2) {
        change(document.querySelector('#blinker-left'), 'addClass', 'hide')
        change(document.querySelector('#blinker-right'), 'removeClass', 'hide')
        change(document.querySelector('#blinker-left'), 'removeClass', 'blink')
        change(document.querySelector('#blinker-right'), 'addClass', 'blink')
    } else if (event.data.blinkers === 3) {
        change(document.querySelector('#blinker-left'), 'removeClass', 'hide')
        change(document.querySelector('#blinker-right'), 'removeClass', 'hide')
        change(document.querySelector('#blinker-left'), 'addClass', 'blink')
        change(document.querySelector('#blinker-right'), 'addClass', 'blink')
    } else if (event.data.blinkers === 0) {
        change(document.querySelector('#blinker-left'), 'addClass', 'hide')
        change(document.querySelector('#blinker-right'), 'addClass', 'hide')
        change(document.querySelector('#blinker-left'), 'removeClass', 'blink')
        change(document.querySelector('#blinker-right'), 'removeClass', 'blink')
    }

    if ((event.data.lights && event.data.highbeams === 0) || (event.data.highbeams && event.data.lights === 0)) {
        change(document.querySelector('#light-dimmed'), 'display', 'block')
        change(document.querySelector('#light-high'), 'display', 'none')
        change(document.querySelector('#light-dimmed'), 'removeClass', 'hide')
    } else if (event.data.highbeams && event.data.lights) {
        change(document.querySelector('#light-dimmed'), 'display', 'none')
        change(document.querySelector('#light-high'), 'display', 'block')
        change(document.querySelector('#light-high'), 'removeClass', 'hide')
    } else if (event.data.lights === 0) {
        change(document.querySelector('#light-high'), 'display', 'none')
        change(document.querySelector('#light-dimmed'), 'display', 'block')
        change(document.querySelector('#light-dimmed'), 'addClass', 'hide')
    }

    if (event.data.doors === 2 || event.data.doors === 3) {
        change(document.querySelector('.driver .doors'), 'removeClass', 'hide')
    } else if (event.data.doors === 0 || event.data.doors === 1) {
        change(document.querySelector('.driver .doors'), 'addClass', 'hide')
    }

    if (event.data.engine < 300) {
        change(document.querySelector('#engine'), 'removeClass', 'hide')
        change(document.querySelector('#engine'), 'addClass', 'blink')
    } else if (event.data.engine <= 400 && event.data.engine >= 300) {
        change(document.querySelector('#engine'), 'removeClass', 'hide')
        change(document.querySelector('#engine'), 'removeClass', 'blink')
    } else if (event.data.engine > 400) {
        change(document.querySelector('#engine'), 'addClass', 'hide')
        change(document.querySelector('#engine'), 'removeClass', 'blink')
    }

    if (event.data.speedLimit > 0) {
        change(document.querySelector('#limiter'), 'removeClass', 'hide')
        change(document.querySelector('#speed-limit'), 'removeClass', 'hide')
        if (document.querySelector('#speed-limit').innerText != event.data.speedLimit) {
            document.querySelector('#speed-limit').innerText = event.data.speedLimit
        }
        if (Math.floor(event.data.speed * 3.6) > event.data.speedLimit) {
            change(document.querySelector('#limiter'), 'addClass', 'blink')
            change(document.querySelector('#speed-limit'), 'addClass', 'blink')
        } else {
            change(document.querySelector('#limiter'), 'removeClass', 'blink')
            change(document.querySelector('#speed-limit'), 'removeClass', 'blink')
        }
    } else {
        change(document.querySelector('#limiter'), 'addClass', 'hide')
        change(document.querySelector('#speed-limit'), 'addClass', 'hide')
        if (document.querySelector('#speed-limit').innerText != 'off') {
            document.querySelector('#speed-limit').innerText = "off"
        }
    }

    if (event.data.seatbelt) {
        change(document.querySelector('.driver .seatbelt'), 'removeClass', 'hide')
    } else if (event.data.seatbelt === false) {
        change(document.querySelector('.driver .seatbelt'), 'addClass', 'hide')
    }
})

function change(element, type, value) {
    if (type === 'margin-top') {
        if (element.style.marginTop != value) {
            element.style.marginTop = value
        }
    } else if (type === 'height') {
        if (element.style.height != value) {
            element.style.height = value
        }
    } else if (type === 'opacity') {
        if (element.style.opacity != value) {
            element.style.opacity = value
        }
    } else if (type === 'display') {
        if (element.style.display != value) {
            element.style.display = value
        }
    } else if (type === 'addClass') {
        if (!element.classList.contains(value)) {
            element.classList.add(value)
        }
    } else if (type === 'removeClass') {
        if (element.classList.contains(value)) {
            element.classList.remove(value)
        }
    }
}

