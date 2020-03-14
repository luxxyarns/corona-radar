/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The annotation views that represent the different types of cycles.
*/
import MapKit

private let multiWheelCycleClusterID = "multiWheelCycle"

/// - Tag: UnicycleAnnotationView
class UnicycleAnnotationView: MKMarkerAnnotationView {

    static let ReuseID = "unicycleAnnotation"

    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "unicycle"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
        markerTintColor = UIColor.unicycleColor
        glyphImage = #imageLiteral(resourceName: "unicycle")
    }
}
 
