// globalMobileUserMap.js
import { LightningElement, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3';
import WORLD_JSON from '@salesforce/resourceUrl/worldgeojson';
import getUserLocations from '@salesforce/apex/GlobalMobileUserMapController.getUserLocations';
import ace_GlobalUserMapLegend from '@salesforce/label/c.ace_GlobalUserMapLegend';
import ace_GlobalUserMapTooltip from '@salesforce/label/c.ace_GlobalUserMapTooltip';

export default class GlobalMobileUserMap extends LightningElement {
	userData = [];
	error;
	isLoading = true;
	d3Initialized = false;
	mapData = null;
	svg = null;
	colorScale = null;
	zoomBehavior = null;
	currentZoom = 1;
	lastTransform = null;

	@wire(getUserLocations)
	wiredUserLocations({ error, data }) {
		this.isLoading = true;
		if (data) {
			this.userData = data;
			this.error = undefined;
			this.initializeMap();
		} else if (error) {
			this.error = error;
			this.userData = [];
		}
		this.isLoading = false;
	}

	@api
	get userData() {
		return this._userData;
	}
	set userData(value) {
		this._userData = value;
		if (this.d3Initialized) {
			this.updateMapColors();
		}
	}

	COUNTRY_COLOR = '#ccc';
	// MAX_COUNTRY_COLOR = '#005A82';
	MAX_COUNTRY_COLOR = '#8D0C18';
	// MIN_COUNTRY_COLOR = '#99BDCD';
	MIN_COUNTRY_COLOR = '#EED2D5';
	OCEAN_COLOR = '#FFFFFF';

	async renderedCallback() {
		if (this.d3Initialized) return;

		try {
			this.isLoading = true;
			await loadScript(this, D3 + '/d3min.js');

			// Wait for d3 to be available on window
			if (!window.d3) {
				throw new Error('D3 failed to load.');
			}

			this.d3 = window.d3;  // Store d3 reference
			this.d3Initialized = true;

			// Add small delay to ensure DOM is ready
			setTimeout(() => {
				this.initializeMap();
			}, 0);
		} catch (error) {
			console.error('Error loading D3:', error.message);
			console.error('Stack trace:', error.stack);
		} finally {
			this.isLoading = false;
		}
	}

	initializeMap() {
		if (!this.d3) return;

		const container = this.template.querySelector('div.map-container');
		if (!container) {
			console.log('Container not found, retrying in next cycle');
			// Retry in the next execution cycle
			window.requestAnimationFrame(() => this.initializeMap());
			return;
		}

		// Clear any existing SVG to prevent duplicates
		container.innerHTML = '';

		const width = container.clientWidth || 960;
		const height = width * 0.5;  // Maintain aspect ratio

		// Create SVG container with responsive sizing
		this.svg = this.d3.select(container)
			.append('svg')
			.attr('viewBox', `0 0 ${width} ${height}`)
			.attr('preserveAspectRatio', 'xMidYMid meet')
			.style('background-color', this.OCEAN_COLOR);

		// Initialize color scale early
		this.colorScale = this.d3.scaleLinear()
			.range([this.MIN_COUNTRY_COLOR, this.MAX_COUNTRY_COLOR])
			.domain([0, 1]); // Set initial domain, will be updated later

		const g = this.svg.append('g');

		// Define projection with better defaults
		const projection = this.d3.geoMercator()
			.scale(width / 2 / Math.PI)
			.center([0, 20])
			.translate([width / 2, height / 2]);

		// Create path generator
		const path = this.d3.geoPath().projection(projection);

		// Load world map data
		this.d3.json(WORLD_JSON)
			.then(geoData => {
				this.mapData = geoData;

				g.selectAll('path')
					.data(geoData.features)
					.enter()
					.append('path')
					.attr('d', path)
					.attr('data-country-code', d => {
						return d.id;
					})
					.style('stroke', '#fff')
					.style('stroke-width', '0.5')
					.style('fill', this.COUNTRY_COLOR)
					.style('vector-effect', 'non-scaling-stroke')
					.on('mouseover', (event, d) => this.handleMouseOver(event, d))
					.on('mouseout', (event, d) => this.handleMouseOut(event, d));

				// Add zoom behavior
				this.zoomBehavior = this.d3.zoom()
					.scaleExtent([1, 8])
					.on('zoom', (event) => {
						this.currentZoom = event.transform.k;
						this.lastTransform = event.transform;
						g.attr('transform', event.transform);
					});

				this.svg.call(this.zoomBehavior);

				// Disable mouse wheel zoom
				this.svg.on('wheel.zoom', null);

				// Add legend
				this.createLegend();

				// Update colors based on initial data
				this.updateMapColors();
			});
	}

	updateMapColors() {
		if (!this.mapData || !this.userData?.features) return;

		// Ensure colorScale exists
		if (!this.colorScale) {
			this.colorScale = this.d3.scaleLinear()
				.range([this.MIN_COUNTRY_COLOR, this.MAX_COUNTRY_COLOR]);
		}

		// Update color scale domain
		const maxCount = this.d3.max(this.userData.features, d => d.properties.count) || 0;
		this.colorScale.domain([0, Math.max(1, maxCount)]); // Ensure non-zero domain

		// Update country colors
		if (this.svg) {
			this.svg.selectAll('path')
				.style('fill', (d) => {
					const countryData = this.userData.features.find(
						item => item.id === d.id
					);
					return countryData ? this.colorScale(countryData.properties.count) : this.COUNTRY_COLOR;
				});

			// Update legend
			this.updateLegend(maxCount);
		}
	}

	createLegend() {
		const width = this.svg.node().getBoundingClientRect().width;
		const height = this.svg.node().getBoundingClientRect().height;

		const legend = this.svg.append('g')
			.attr('class', 'legend')
			.attr('transform', `translate(${width - 220}, ${height - 30})`); // Move to bottom right

		legend.append('text')
			.attr('class', 'legend-title')
			.attr('x', 0)
			.attr('y', -10)
			.style('fill', '#54698d')
			.text(`${ace_GlobalUserMapLegend} Count`);

		const gradientData = Array.from({ length: 100 }, (_, i) => i / 100);

		legend.selectAll('rect')
			.data(gradientData)
			.enter()
			.append('rect')
			.attr('x', (d, i) => i * 2)
			.attr('width', 2)
			.attr('height', 10)
			.style('fill', d => this.colorScale(d)); // Set initial gradient colors
	}

	updateLegend(maxCount) {
		const legend = this.svg.select('.legend');

		// Update gradient colors with new scale
		legend.selectAll('rect')
			.style('fill', d => this.colorScale(d * maxCount));

		// Update legend labels with explicit fill color
		legend.selectAll('.legend-labels').remove();
		const labelColor = '#54698d';

		legend.append('text')
			.attr('class', 'legend-labels')
			.attr('x', 0)
			.attr('y', 25)
			.style('font-size', '12px')
			.style('fill', labelColor)
			.text('0');

		legend.append('text')
			.attr('class', 'legend-labels')
			.attr('x', 190)
			.attr('y', 25)
			.style('font-size', '12px')
			.style('fill', labelColor)
			.text(maxCount);
	}

	handleMouseOver(event, d) {
		const svgBounds = this.svg.node().getBoundingClientRect();
		const mouseX = this.d3.pointer(event)[0];
		const mouseY = this.d3.pointer(event)[1];

		const tooltip = this.svg.append('g')
			.attr('class', 'tooltip');

		const countryData = this.userData.features.find(
			item => item.id === d.id
		);

		const countryName = countryData ? countryData.properties.name : d.properties.name;
		const count = countryData ? countryData.properties.count : 0;

		// Create temporary elements to measure dimensions
		const tempGroup = tooltip.append('g');
			let tooltipText = `${ace_GlobalUserMapTooltip}: ${count.toLocaleString()}`;

		const tempName = tempGroup.append('text')
			.attr('x', 0)
			.attr('y', 0)
			.style('font-size', '12px')
			.style('font-weight', 'bold')
			.text(countryName);


			tooltip.append('text')
				.attr('x', 10)
				.attr('y', 35)
				.style('font-size', '12px')
				.text(tooltipText);

		// Get bounding boxes
		const nameBox = tempName.node().getBBox();
		const countBox = tempCount.node().getBBox();

		// Calculate tooltip dimensions
		const boxWidth = Math.max(nameBox.width, countBox.width) + 20;
		const boxHeight = 45;

		// Remove temporary elements
		tempGroup.remove();

		// Calculate position adjustments
		let xPos = mouseX + 10;
		let yPos = mouseY - 10;

		// Adjust horizontal position if tooltip would overflow right edge
		if (xPos + boxWidth > svgBounds.width) {
			xPos = mouseX - boxWidth - 10;
		}

		// Adjust vertical position if tooltip would overflow top or bottom
		if (yPos - boxHeight < 0) {
			yPos = mouseY + 20;
		} else if (yPos > svgBounds.height) {
			yPos = mouseY - boxHeight - 10;
		}

		// Position the tooltip
		tooltip.attr('transform', `translate(${xPos},${yPos})`);

		// Create background rectangle
		tooltip.append('rect')
			.attr('width', boxWidth)
			.attr('height', boxHeight)
			.attr('fill', 'rgba(255, 255, 255, 0.9)')
			.attr('rx', 5)
			.attr('ry', 5)
			.style('filter', 'drop-shadow(2px 2px 2px rgba(0,0,0,0.2))');

		// Add the actual text elements
		tooltip.append('text')
			.attr('x', 10)
			.attr('y', 20)
			.style('font-size', '12px')
			.style('font-weight', 'bold')
			.text(countryName);

		tooltip.append('text')
			.attr('x', 10)
			.attr('y', 35)
			.style('font-size', '12px')
			.text(`Assignees: ${count.toLocaleString()}`);
	}

	handleMouseOut() {
		this.svg.selectAll('.tooltip').remove();
	}

	handleZoomIn() {
		if (!this.svg || !this.zoomBehavior) return;

		const svgNode = this.svg.node();
		const bounds = svgNode.getBoundingClientRect();
		const newZoom = Math.min(this.currentZoom * 1.5, 8);

		if (this.lastTransform) {
			// Calculate the center point of the current view
			const viewCenter = [
				(bounds.width / 2 - this.lastTransform.x) / this.lastTransform.k,
				(bounds.height / 2 - this.lastTransform.y) / this.lastTransform.k
			];

			// Create transform that maintains the current view center
			const transform = this.d3.zoomIdentity
				.translate(
					bounds.width / 2 - viewCenter[0] * newZoom,
					bounds.height / 2 - viewCenter[1] * newZoom
				)
				.scale(newZoom);

			this.svg
				.transition()
				.duration(300)
				.call(this.zoomBehavior.transform, transform);
		}
	}

	handleZoomOut() {
		if (!this.svg || !this.zoomBehavior) return;

		const svgNode = this.svg.node();
		const bounds = svgNode.getBoundingClientRect();
		const viewCenter = [bounds.width / 2, bounds.height / 2];
		const newZoom = Math.max(this.currentZoom / 1.5, 1);

		// Always zoom out towards the center of the map
		const transform = this.d3.zoomIdentity
			.translate(viewCenter[0], viewCenter[1])
			.scale(newZoom)
			.translate(-viewCenter[0], -viewCenter[1]);

		this.svg
			.transition()
			.duration(300)
			.call(this.zoomBehavior.transform, transform);
	}

	disconnectedCallback() {
		const container = this.template.querySelector('.map-container');
		if (container) {
			container.innerHTML = '';
		}
	}
}